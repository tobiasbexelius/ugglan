import Flow
import Form
import Foundation
import hCore
import hCoreUI
import UIKit

struct MultiActionNumberRow {
    let data: EmbarkNumberMultiActionData
}

extension MultiActionNumberRow: Viewable {
    func materialize(events _: ViewableEvents) -> (UIView, MultiActionStoreSignal) {
        let bag = DisposeBag()

        let containerView = UIView()
        bag += containerView.traitCollectionSignal.onValue { trait in
            switch trait.userInterfaceStyle {
            case .dark:
                containerView.backgroundColor = .grayscale(.grayFive)
            default:
                containerView.backgroundColor = .brand(.primaryBackground())
            }
        }
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 10
        view.edgeInsets = .init(top: 16, left: 16, bottom: 16, right: 16)

        containerView.addSubview(view)
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let titleLabel = UILabel()
        titleLabel.style = .brand(.body(color: .primary))
        titleLabel.text = data.label
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)

        view.addArrangedSubview(titleLabel)

        let masking = Masking(type: .digits)
        let numberField = EmbarkInput(
            placeholder: data.placeholder,
            keyboardType: masking.keyboardType,
            textContentType: masking.textContentType,
            autocapitalisationType: masking.autocapitalizationType,
            insets: .zero,
            masking: masking,
            fieldStyle: .embarkInputSmall,
            textFieldAlignment: .right
        )

        return (containerView, Signal { callback in
            bag += view.addArranged(numberField).onValue { text in
                callback([data.key: text])
            }

            return bag
        })
    }
}
