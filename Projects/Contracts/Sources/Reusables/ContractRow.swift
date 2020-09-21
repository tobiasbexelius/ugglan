import Flow
import Form
import Foundation
import hCore
import hCoreUI
import hGraphQL
import UIKit

struct ContractRow: Hashable {
    static func == (lhs: ContractRow, rhs: ContractRow) -> Bool {
        lhs.displayName == rhs.displayName
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(displayName)
    }

    let contract: GraphQL.ContractsQuery.Data.Contract
    let displayName: String
    let type: ContractType

    enum ContractType {
        case swedishApartment
        case swedishHouse
        case norwegianTravel
        case norwegianHome
    }

    let sectionStyle = DynamicSectionStyle.brandGroupedInset(separatorType: .none)
}

extension Date {
    public var localizationDescription: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Foundation.Locale(identifier: Localization.Locale.currentLocale.rawValue)
        dateFormatter.dateStyle = .long
        let dateString = dateFormatter.string(from: self)

        return dateString
    }
}

extension ContractRow: Reusable {
    func makeStateIndicator() -> UILabel {
        let label = UILabel(value: "", style: .brand(.subHeadline(color: .secondary)))

        if let _ = contract.status.asPendingStatus {
            label.value = L10n.dashboardInsuranceStatusInactiveNoStartdate
        } else if let status = contract.status.asActiveInFutureStatus {
            label.value = L10n.dashboardInsuranceStatusInactiveStartdate(status.futureInception?.localDateToDate?.localizationDescription ?? "")
        } else if let _ = contract.status.asActiveStatus {
            label.value = L10n.dashboardInsuranceStatusActive
        } else if let status = contract.status.asActiveInFutureAndTerminatedInFutureStatus {
            label.value = L10n.dashboardInsuranceStatusInactiveStartdateTerminatedInFuture(
                status.futureInception?.localDateToDate?.localizationDescription ?? "",
                status.futureTermination?.localDateToDate?.localizationDescription ?? ""
            )
        } else if let status = contract.status.asTerminatedInFutureStatus {
            label.value = L10n.dashboardInsuranceStatusActiveTerminationdate(status.futureTermination?.localDateToDate?.localizationDescription ?? "")
        } else if let _ = contract.status.asTerminatedTodayStatus {
            label.value = L10n.dashboardInsuranceStatusTerminatedToday
        } else if let _ = contract.status.asTerminatedStatus {
            label.value = L10n.dashboardInsuranceStatusTerminated
        }

        return label
    }

    func makeSwitcherRow() -> (Disposable, [ThreeEither<SectionView, UIView, Spacing>]) {
        if contract.switchedFromInsuranceProvider == nil {
            return (NilDisposer(), [])
        }

        let bag = DisposeBag()

        let section = SectionView()
        section.dynamicStyle = sectionStyle

        if let status = contract.status.asActiveInFutureStatus {
            let row = RowView()

            let date = status
                .futureInception?
                .localDateToDate?
                .localizationDescription ?? ""

            bag += row.append(
                MultilineLabel(
                    value: L10n.contractPendingHasDate(
                        date
                    ),
                    style: .brand(.subHeadline(color: .primary))
                )
            )

            section.append(row)
        } else if let _ = contract.status.asPendingStatus {
            let row = RowView()

            bag += row.append(
                MultilineLabel(
                    value: L10n.contractPendingNoDate,
                    style: .brand(.subHeadline(color: .primary))
                )
            )

            section.append(row)
        } else {
            return (NilDisposer(), [])
        }

        return (bag, [
            .make(section),
            .make(Spacing(height: 10)),
        ])
    }

    func makeInfoIcon() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = hCoreUIAssets.infoLarge.image

        imageView.snp.makeConstraints { make in
            make.width.equalTo(20)
        }

        return imageView
    }

    var daysUntilRenewal: Int? {
        let formatter = DateFormatter.iso8601
        guard let date = formatter.date(from: contract.upcomingRenewal?.renewalDate ?? "") else {
            return nil
        }

        let calendar = Calendar.current

        let dateFrom = calendar.startOfDay(for: Date())
        let dateTo = calendar.startOfDay(for: date)

        let components = calendar.dateComponents([.day], from: dateFrom, to: dateTo)

        return components.day
    }

    func makeRenewalRow() -> (DisposeBag, [ThreeEither<SectionView, UIView, Spacing>]) {
        let bag = DisposeBag()

        let section = SectionView()
        section.dynamicStyle = sectionStyle
        let row = RowView()

        let textContainer = UIStackView()
        textContainer.layoutMargins = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        textContainer.spacing = 5
        textContainer.isLayoutMarginsRelativeArrangement = true
        textContainer.axis = .vertical

        textContainer.addArrangedSubview(
            UILabel(
                value: L10n.dashboardRenewalPrompterTitle,
                style: .brand(.headline(color: .primary))
            )
        )

        bag += textContainer.addArranged(
            MultilineLabel(
                value: L10n.dashboardRenewalPrompterBody(daysUntilRenewal ?? 0),
                style: .brand(.subHeadline(color: .secondary))
            )
        )

        row.append(textContainer)

        row.append(makeInfoIcon())

        bag += section.append(row).onValue { _ in
            guard let url = URL(string: self.contract.upcomingRenewal?.draftCertificateUrl) else {
                return
            }
            section.viewController?.present(
                InsuranceDocument(url: url, title: "").withCloseButton,
                style: .detented(.large)
            )
        }

        return (bag, [
            .make(section),
        ])
    }

    func makeInfoRow() -> (DisposeBag, [ThreeEither<SectionView, UIView, Spacing>]) {
        let bag = DisposeBag()

        let section = SectionView()
        section.dynamicStyle = sectionStyle
        let row = RowView()

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit

        if let _ = contract.currentAgreement.asNorwegianTravelAgreement {
            imageView.image = Asset.insuranceInfo.image
        } else if let _ = contract.currentAgreement.asSwedishHouseAgreement {
            imageView.image = Asset.house.image
        } else {
            imageView.image = Asset.apartment.image
        }

        row.append(imageView)

        imageView.snp.makeConstraints { make in
            make.width.equalTo(32)
            make.height.equalTo(32)
        }

        let textContainer = UIStackView()
        textContainer.layoutMargins = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        textContainer.spacing = 5
        textContainer.isLayoutMarginsRelativeArrangement = true
        textContainer.axis = .vertical

        textContainer.addArrangedSubview(
            UILabel(value: L10n.dashboardMyInfoTitle, style: .brand(.headline(color: .primary)))
        )
        textContainer.addArrangedSubview(
            UILabel(value: contract.currentAgreement.summary ?? "", style: .brand(.subHeadline(color: .secondary)))
        )

        row.append(textContainer)

        row.append(makeInfoIcon())

        bag += section.append(row).onValue { _ in
            section.viewController?.present(
                ContractDetail(contract: self.contract).withCloseButton,
                style: .detented(.scrollViewContentSize(20), .large)
            )
        }

        return (bag, [
            .make(section),
        ])
    }

    func makeCoverageRow() -> (DisposeBag, [ThreeEither<SectionView, UIView, Spacing>]) {
        let bag = DisposeBag()

        let section = SectionView()
        section.dynamicStyle = sectionStyle
        let row = RowView()

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = Asset.coverage.image
        row.append(imageView)

        imageView.snp.makeConstraints { make in
            make.width.equalTo(32)
            make.height.equalTo(32)
        }

        let textContainer = UIStackView()
        textContainer.layoutMargins = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        textContainer.spacing = 5
        textContainer.isLayoutMarginsRelativeArrangement = true
        textContainer.axis = .vertical

        textContainer.addArrangedSubview(
            UILabel(
                value: L10n.dashboardMyCoverageTitle,
                style: .brand(.headline(color: .primary))
            )
        )
        textContainer.addArrangedSubview(
            UILabel(
                value: L10n.dashboardMyCoverageSubtitle,
                style: .brand(.subHeadline(color: .secondary))
            )
        )

        row.append(textContainer)

        row.append(makeInfoIcon())

        bag += section.append(row).onValue { _ in
            let contractCoverage = ContractCoverage(
                perilFragments: self.contract.perils.compactMap { $0.fragments.perilFragment },
                insurableLimitFragments: self.contract.insurableLimits.compactMap { $0.fragments.insurableLimitFragment }
            )
            section.viewController?.present(contractCoverage.withCloseButton, style: .detented(.large))
        }

        return (bag, [
            .make(section),
        ])
    }

    func makeDocumentsRow() -> (DisposeBag, [ThreeEither<SectionView, UIView, Spacing>]) {
        let bag = DisposeBag()

        let section = SectionView()
        section.dynamicStyle = sectionStyle
        let row = RowView()

        let imageView = UIImageView()
        imageView.image = Asset.documents.image
        imageView.contentMode = .scaleAspectFit
        row.append(imageView)

        imageView.snp.makeConstraints { make in
            make.width.equalTo(32)
            make.height.equalTo(32)
        }

        let textContainer = UIStackView()
        textContainer.layoutMargins = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        textContainer.spacing = 5
        textContainer.isLayoutMarginsRelativeArrangement = true
        textContainer.axis = .vertical

        textContainer.addArrangedSubview(
            UILabel(
                value: L10n.dashboardMyDocumentsTitle,
                style: .brand(.headline(color: .primary))
            )
        )
        textContainer.addArrangedSubview(
            UILabel(
                value: L10n.dashboardMyDocumentsSubtitle,
                style: .brand(.subHeadline(color: .secondary))
            )
        )

        row.append(textContainer)

        row.append(makeInfoIcon())

        bag += section.append(row).onValue { _ in
            section.viewController?.present(
                ContractDocuments(contract: self.contract).withCloseButton,
                style: .detented(.scrollViewContentSize(20), .large),
                options: [.defaults, .allowSwipeDismissAlways]
            )
        }

        return (bag, [
            .make(section),
        ])
    }

    func makeFormContent() -> (DisposeBag, [ThreeEither<SectionView, UIView, Spacing>]) {
        let bag = DisposeBag()
        let header = UIStackView()
        header.axis = .vertical
        header.spacing = 10
        header.addArrangedSubview(UILabel(
            value: displayName,
            style: .brand(.headline(color: .primary))
        ))
        header.addArrangedSubview(makeStateIndicator())

        let (switcherRowBag, switcherRowContent) = makeSwitcherRow()
        bag += switcherRowBag

        let (renewalRowBag, renewalRowContent) = makeRenewalRow()
        bag += renewalRowBag

        let (infoRowBag, infoRowContent) = makeInfoRow()
        bag += infoRowBag

        let (coverageRowBag, coverageRowContent) = makeCoverageRow()
        bag += coverageRowBag

        let (documentsRowBag, documentsRowContent) = makeDocumentsRow()
        bag += documentsRowBag

        return (
            bag,
            [
                [
                    .make(header),
                    .make(Spacing(height: 10)),
                ],
                contract.upcomingRenewal != nil ? renewalRowContent : nil,
                contract.upcomingRenewal != nil ? [.make(Spacing(height: 10))] : nil,
                switcherRowContent,
                infoRowContent,
                [.make(Spacing(height: 10))],
                coverageRowContent,
                [.make(Spacing(height: 10))],
                documentsRowContent,
            ].compactMap { $0 }.flatMap { $0 }
        )
    }

    static func makeAndConfigure() -> (make: UIView, configure: (ContractRow) -> Disposable) {
        let view = UIView()

        let form = FormView()
        form.dynamicStyle = .init(generateStyle: { _ in
            .init(insets: UIEdgeInsets(top: 0, left: 15, bottom: 20, right: 15))
        })

        view.addSubview(form)

        form.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }

        return (view, { `self` in
            let bag = DisposeBag()

            let (contentBag, contents) = self.makeFormContent()
            bag += contentBag

            contents.forEach { content in
                switch content {
                case let .left(section):
                    form.append(section)
                    bag += {
                        section.removeFromSuperview()
                    }
                case let .right(viewOrSpacing):
                    switch viewOrSpacing {
                    case let .left(view):
                        form.append(view)
                        bag += {
                            view.removeFromSuperview()
                        }
                    case let .right(spacing):
                        bag += form.append(spacing)
                    }
                }
            }

            return bag
        })
    }
}
