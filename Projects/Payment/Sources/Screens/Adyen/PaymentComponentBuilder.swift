import Adyen
import AdyenCard
import Foundation
import hCore
import hCoreUI

struct AdyenPaymentBuilder: PaymentComponentBuilder {
    let encryptionPublicKey: String

    var formComponentStyle: FormComponentStyle {
        var formComponent = FormComponentStyle()
        formComponent.header.title.font = Fonts.fontFor(style: .title1)
        formComponent.header.title.color = .clear
        formComponent.mainButtonItem.button.backgroundColor = .brand(.secondaryButtonBackgroundColor)
        formComponent.mainButtonItem.button.title.color = .brand(.secondaryButtonTextColor)
        formComponent.mainButtonItem.button.title.font = Fonts.fontFor(style: .title3)
        formComponent.mainButtonItem.button.cornerRounding = .fixed(6)
        formComponent.textField.title.font = Fonts.fontFor(style: .caption1)
        formComponent.textField.text.font = Fonts.fontFor(style: .body)
        formComponent.textField.tintColor = .brand(.primaryTintColor)
        formComponent.textField.errorColor = .brand(.destructive)
        formComponent.switch.title.font = Fonts.fontFor(style: .footnote)
        formComponent.backgroundColor = .brand(.secondaryBackground())
        formComponent.textField.backgroundColor = .brand(.secondaryBackground())
        formComponent.header.backgroundColor = .brand(.secondaryBackground())
        formComponent.hintLabel.font = Fonts.fontFor(style: .footnote)
        return formComponent
    }

    func build(paymentMethod: StoredCardPaymentMethod) -> PaymentComponent? {
        let component = CardComponent(paymentMethod: paymentMethod, publicKey: encryptionPublicKey, style: formComponentStyle)
        component.showsStorePaymentMethodField = false
        return component
    }

    func build(paymentMethod _: StoredPaymentMethod) -> PaymentComponent? {
        nil
    }

    func build(paymentMethod _: StoredBCMCPaymentMethod) -> PaymentComponent? {
        nil
    }

    func build(paymentMethod: CardPaymentMethod) -> PaymentComponent? {
        let component = CardComponent(paymentMethod: paymentMethod, publicKey: encryptionPublicKey, style: formComponentStyle)
        component.showsStorePaymentMethodField = false
        return component
    }

    func build(paymentMethod _: BCMCPaymentMethod) -> PaymentComponent? {
        nil
    }

    func build(paymentMethod _: IssuerListPaymentMethod) -> PaymentComponent? {
        nil
    }

    func build(paymentMethod _: SEPADirectDebitPaymentMethod) -> PaymentComponent? {
        nil
    }

    func build(paymentMethod: ApplePayPaymentMethod) -> PaymentComponent? {
        do {
            let merchantIdentifier: String

            switch ApplicationState.getTargetEnvironment() {
            case .staging:
                merchantIdentifier = "merchant.com.hedvig.test.app"
            case .production:
                merchantIdentifier = "merchant.com.hedvig.app"
            case .custom:
                merchantIdentifier = "merchant.com.hedvig.test.app"
            }

            let configuration = ApplePayComponent.Configuration(
                summaryItems: [.init(label: "Hedvig", amount: 0, type: .pending)],
                merchantIdentifier: merchantIdentifier
            )

            let payment = Payment(
                amount: Payment.Amount(
                    value: 0,
                    currencyCode: Localization.Locale.currentLocale.market.currencyCode
                ),
                countryCode: Localization.Locale.currentLocale.market.rawValue
            )

            return try ApplePayComponent(
                paymentMethod: paymentMethod,
                payment: payment,
                configuration: configuration
            )
        } catch {
            print("Failed to instantiate ApplePayComponent because of error: \(error.localizedDescription)")
            return nil
        }
    }

    func build(paymentMethod _: WeChatPayPaymentMethod) -> PaymentComponent? {
        nil
    }

    func build(paymentMethod _: QiwiWalletPaymentMethod) -> PaymentComponent? {
        nil
    }

    func build(paymentMethod _: MBWayPaymentMethod) -> PaymentComponent? {
        nil
    }

    func build(paymentMethod _: BLIKPaymentMethod) -> PaymentComponent? {
        nil
    }

    func build(paymentMethod: PaymentMethod) -> PaymentComponent? {
        EmptyPaymentComponent(paymentMethod: paymentMethod)
    }
}
