import Apollo
import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL
import Presentation
import UIKit

public struct MovingFlowIntro {
    @Inject var client: ApolloClient
    @ReadWriteState var section = MovingFlowIntroState.none
    var menu: Menu

    public init(menu: Menu) {
        self.menu = menu
    }
}

typealias Contract = GraphQL.UpcomingAgreementQuery.Data.Contract
internal typealias UpcomingAgreementDetailsTable = Contract.UpcomingAgreementDetailsTable

enum MovingFlowIntroState {
    case manual
    case existing(UpcomingAgreementDetailsTable)
    case normal(String)
    case none

    var button: Button? {
        switch self {
        case .existing, .manual:
            return Button(
                title: L10n.MovingIntro.manualHandlingButtonText,
                type: .standardIcon(
                    backgroundColor: .brand(.secondaryButtonBackgroundColor),
                    textColor: .brand(.secondaryButtonTextColor),
                    icon: .left(image: hCoreUIAssets.chat.image, width: 22)
                )
            )
        case .normal:
            return Button(title: L10n.MovingIntro.openFlowButtonText, type: .standard(backgroundColor: .brand(.secondaryButtonBackgroundColor), textColor: .brand(.secondaryButtonTextColor)))
        default:
            return nil
        }
    }

    var route: MovingFlowRoute? {
        switch self {
        case .manual, .existing:
            return .chat
        case let .normal(storyName):
            return .embark(name: storyName)
        case .none:
            return nil
        }
    }
}

public enum MovingFlowRoute {
    case chat
    case embark(name: String)
}

extension MovingFlowIntro: Presentable {
    public func materialize() -> (UIViewController, FiniteSignal<MovingFlowRoute>) {
        let bag = DisposeBag()
        let viewController = UIViewController()

        let view = UIView()
        view.backgroundColor = .brand(.primaryBackground())

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.alignment = .center
        stackView.spacing = 16
        stackView.insetsLayoutMarginsFromSafeArea = true
        stackView.edgeInsets = UIEdgeInsets(top: 20, left: 16, bottom: 0, right: 16)

        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.width.centerX.centerY.equalToSuperview()
            make.top.greaterThanOrEqualToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }

        let optionsButton = UIBarButtonItem(image: hCoreUIAssets.menuIcon.image, style: .plain, target: nil, action: nil)
        viewController.navigationItem.rightBarButtonItem = optionsButton

        bag += optionsButton.attachSinglePressMenu(
            viewController: viewController,
            menu: menu
        )

        viewController.view = view

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.setContentHuggingPriority(.defaultLow, for: .vertical)

        #warning("ADD ADDRESS DETAILS TABLE VIEW HERE LATER")
        let tableView = UIView()
        tableView.isHidden = true

        var titleLabel = MultilineLabel(value: "", style: .brand(.title2(color: .primary)))
        var descriptionLabel = MultilineLabel(value: "", style: .brand(.body(color: .secondary)))

        stackView.addArrangedSubview(imageView)
        bag += stackView.addArranged(titleLabel) { labelView in labelView.textAlignment = .center }
        bag += stackView.addArranged(descriptionLabel) { labelView in labelView.textAlignment = .center }
        stackView.addArrangedSubview(tableView)

        bag += $section.onValue { state in
            switch state {
            case .manual:
                titleLabel.value = L10n.MovingIntro.manualHandlingButtonText
                descriptionLabel.value = L10n.MovingIntro.manualHandlingDescription
                imageView.image = hCoreUIAssets.helicopter.image
            case let .existing(table):
                titleLabel.value = L10n.MovingIntro.existingMoveTitle
                descriptionLabel.value = L10n.MovingIntro.existingMoveDescription
                imageView.image = nil
                tableView.isHidden = false
            case .normal:
                titleLabel.value = L10n.MovingIntro.title
                descriptionLabel.value = L10n.MovingIntro.description
                imageView.image = hCoreUIAssets.notifications.image
            case .none:
                break
            }
        }

        let activeContractBundles: Future<[GraphQL.ActiveContractBundlesQuery.Data.ActiveContractBundle]> = client.fetch(query: GraphQL.ActiveContractBundlesQuery())
            .map { data in
                data.activeContractBundles
            }

        bag += client.fetch(query: GraphQL.UpcomingAgreementQuery(locale: Localization.Locale.currentLocale.asGraphQLLocale())).onValue { data in
            if let contract = data.contracts.first(where: { $0.status.asActiveStatus?.upcomingAgreementChange != nil }) {
                $section.value = .existing(contract.upcomingAgreementDetailsTable)
            } else {
                bag += activeContractBundles.onValue { bundles in
                    if let bundle = bundles.first(where: { $0.angelStories.addressChange != nil }) {
                        $section.value = .normal(bundle.angelStories.addressChange?.displayValue ?? "")
                    } else {
                        $section.value = .manual
                    }
                }
            }
        }

        return (viewController, FiniteSignal { callbacker in

            bag += $section.atOnce().onValueDisposePrevious { state in
                let innerBag = DisposeBag()

                if let button = state.button {
                    innerBag += view.add(button) { buttonView in
                        buttonView.snp.makeConstraints { make in
                            make.bottom.equalToSuperview().inset(20 + viewController.view.safeAreaInsets.bottom)
                            make.leading.trailing.equalToSuperview().inset(16)
                        }
                    }

                    innerBag += button.onTapSignal.onValue {
                        callbacker(.value(state.route ?? .chat))
                    }
                }

                return innerBag
            }

            return bag
        })
    }
}