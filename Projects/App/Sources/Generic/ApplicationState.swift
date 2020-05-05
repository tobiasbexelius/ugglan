//
//  ApplicationState.swift
//  ugglan
//
//  Created by Gustaf Gunér on 2019-05-22.
//  Hedvig
//

import Flow
import Foundation
import UIKit

struct Localization {
    enum Locale: String, CaseIterable {
        public static var currentLocale: Locale = .sv_SE
        case sv_SE
        case en_SE
        case en_NO
        case nb_NO
        
        enum Market: String {
            case no = "NO"
            case se = "SE"
        }

        var market: Market {
            switch self {
            case .sv_SE:
                return .se
            case .en_SE:
                return .se
            case .en_NO:
                return .no
            case .nb_NO:
                return .no
            }
        }

        var acceptLanguageHeader: String {
            switch self {
            case .sv_SE:
                return "sv-SE"
            case .en_SE:
                return "en-SE"
            case .en_NO:
                return "en-NO"
            case .nb_NO:
                return "nb-NO"
            }
        }

        var code: String {
            switch self {
            case .sv_SE:
                return "sv_SE"
            case .en_SE:
                return "en_SE"
            case .en_NO:
                return "en_NO"
            case .nb_NO:
                return "nb_NO"
            }
        }

        var lprojCode: String {
            switch self {
            case .sv_SE:
                return "sv-SE"
            case .en_SE:
                return "en-SE"
            case .en_NO:
                return "en-NO"
            case .nb_NO:
                return "nb-NO"
            }
        }
    }
}

extension Localization.Locale {
    func asGraphQLLocale() -> Locale {
        switch self {
        case .sv_SE:
            return .svSe
        case .en_SE:
            return .enSe
        case .nb_NO:
            return .nbNo
        case .en_NO:
            return .enNo
        }
    }
}

public struct L10nDerivation {
    let table: String
    let key: String
    let args: [CVarArg]
    
    /// render the text key again, useful if you have changed the language during runtime
    func render() -> String {
        return L10n.tr(table, key, args)
    }
}

public extension String {
    static var derivedFromL10n: UInt8 = 0

    /// set when String is derived from a L10n key
    var derivedFromL10n: L10nDerivation? {
        get {
            guard let value = objc_getAssociatedObject(
                self,
                &String.derivedFromL10n
            ) as? L10nDerivation? else {
                return nil
            }

            return value
        }
        set(newValue) {
            objc_setAssociatedObject(
                self,
                &String.derivedFromL10n,
                newValue,
                objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
}

struct ApplicationState {
    public static let lastNewsSeenKey = "lastNewsSeen"

    enum Screen: String {
        case marketing, onboardingChat, offer, loggedIn, languagePicker, marketPicker

        func isOneOf(_ possibilities: Set<Self>) -> Bool {
            possibilities.contains(self)
        }
    }

    private static let key = "applicationState"

    static func preserveState(_ screen: Screen) {
        UserDefaults.standard.set(screen.rawValue, forKey: key)
    }

    static var currentState: Screen? {
        guard
            let applicationStateRawValue = UserDefaults.standard.value(forKey: key) as? String,
            let applicationState = Screen(rawValue: applicationStateRawValue) else {
            return nil
        }
        return applicationState
    }

    static func hasPreviousState() -> Bool {
        return UserDefaults.standard.value(forKey: key) as? String != nil
    }

    private static let firebaseMessagingTokenKey = "firebaseMessagingToken"

    static func setFirebaseMessagingToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: ApplicationState.firebaseMessagingTokenKey)
    }

    static func getFirebaseMessagingToken() -> String? {
        UserDefaults.standard.value(forKey: firebaseMessagingTokenKey) as? String
    }

    static func hasLastNewsSeen() -> Bool {
        return UserDefaults.standard.value(forKey: lastNewsSeenKey) as? String != nil
    }

    static func getLastNewsSeen() -> String {
        return UserDefaults.standard.string(forKey: ApplicationState.lastNewsSeenKey) ?? "2.8.3"
    }

    static func setLastNewsSeen() {
        UserDefaults.standard.set(Bundle.main.appVersion, forKey: ApplicationState.lastNewsSeenKey)
    }

    private static let preferredLocaleKey = "preferredLocale"

    static func setPreferredLocale(_ locale: Localization.Locale) {
        UserDefaults.standard.set(locale.rawValue, forKey: ApplicationState.preferredLocaleKey)
    }

    static var hasPreferredLocale: Bool {
        return UserDefaults.standard.value(forKey: preferredLocaleKey) as? String != nil
    }

    static var preferredLocale: Localization.Locale {
        guard
            let preferredLocaleRawValue = UserDefaults.standard.value(forKey: preferredLocaleKey) as? String,
            let preferredLocale = Localization.Locale(rawValue: preferredLocaleRawValue) else {
            let availableLanguages = Localization.Locale.allCases.map { $0.rawValue }

            let bestMatchedLanguage = Bundle.preferredLocalizations(
                from: availableLanguages
            ).first

            if let bestMatchedLanguage = bestMatchedLanguage {
                return Localization.Locale(rawValue: bestMatchedLanguage) ?? .en_SE
            }
            return .en_SE
        }

        return preferredLocale
    }

    private static let targetEnvironmentKey = "targetEnvironment"

    enum Environment: Hashable {
        case production
        case staging
        case custom(endpointURL: URL, wsEndpointURL: URL, assetsEndpointURL: URL)

        fileprivate struct RawCustomStorage: Codable {
            let endpointURL: URL
            let wsEndpointURL: URL
            let assetsEndpointURL: URL
        }

        var rawValue: String {
            switch self {
            case .production:
                return "production"
            case .staging:
                return "staging"
            case let .custom(endpointURL, wsEndpointURL, assetsEndpointURL):
                let rawCustomStorage = RawCustomStorage(
                    endpointURL: endpointURL,
                    wsEndpointURL: wsEndpointURL,
                    assetsEndpointURL: assetsEndpointURL
                )
                let data = try? JSONEncoder().encode(rawCustomStorage)

                if let data = data {
                    return String(data: data, encoding: .utf8) ?? "staging"
                }

                return "staging"
            }
        }

        var displayName: String {
            switch self {
            case .production:
                return "production"
            case .staging:
                return "staging"
            case .custom:
                return "custom"
            }
        }

        init?(rawValue: String) {
            switch rawValue {
            case "production":
                self = .production
            case "staging":
                self = .staging
            default:
                guard let data = rawValue.data(using: .utf8) else {
                    return nil
                }

                guard let rawCustomStorage = try? JSONDecoder().decode(RawCustomStorage.self, from: data) else {
                    return nil
                }

                self = .custom(
                    endpointURL: rawCustomStorage.endpointURL,
                    wsEndpointURL: rawCustomStorage.wsEndpointURL,
                    assetsEndpointURL: rawCustomStorage.assetsEndpointURL
                )
            }
        }

        var apolloEnvironmentConfig: ApolloEnvironmentConfig {
            switch getTargetEnvironment() {
            case .staging:
                return ApolloEnvironmentConfig(
                    endpointURL: URL(string: "https://graphql.dev.hedvigit.com/graphql")!,
                    wsEndpointURL: URL(string: "wss://graphql.dev.hedvigit.com/subscriptions")!,
                    assetsEndpointURL: URL(string: "https://graphql.dev.hedvigit.com")!
                )
            case .production:
                return ApolloEnvironmentConfig(
                    endpointURL: URL(string: "https://giraffe.hedvig.com/graphql")!,
                    wsEndpointURL: URL(string: "wss://giraffe.hedvig.com/subscriptions")!,
                    assetsEndpointURL: URL(string: "https://giraffe.hedvig.com")!
                )
            case let .custom(endpointURL, wsEndpointURL, assetsEndpointURL):
                return ApolloEnvironmentConfig(
                    endpointURL: endpointURL,
                    wsEndpointURL: wsEndpointURL,
                    assetsEndpointURL: assetsEndpointURL
                )
            }
        }
    }

    static func setTargetEnvironment(_ environment: Environment) {
        UserDefaults.standard.set(environment.rawValue, forKey: targetEnvironmentKey)
    }

    static var hasOverridenTargetEnvironment: Bool {
        return UserDefaults.standard.value(forKey: targetEnvironmentKey) != nil
    }

    static func getTargetEnvironment() -> Environment {
        guard
            let targetEnvirontmentRawValue = UserDefaults.standard.value(forKey: targetEnvironmentKey) as? String,
            let targetEnvironment = Environment(rawValue: targetEnvirontmentRawValue) else {
            #if APP_VARIANT_PRODUCTION
                return .production
            #elseif APP_VARIANT_STAGING
                return .staging
            #else
                return .production
            #endif
        }
        return targetEnvironment
    }

    static func presentRootViewController(_ window: UIWindow) -> Disposable {
        guard let applicationState = currentState
        else {
            return window.present(
                MarketPicker(),
                options: [.defaults, .prefersNavigationBarHidden(true)],
                animated: false
            )
        }

        switch applicationState {
        case .marketPicker:
            return window.present(
                MarketPicker(),
                options: [.defaults, .prefersNavigationBarHidden(true)],
                animated: false
            )
        case .languagePicker:
            return window.present(
                PreMarketingLanguagePicker(),
                options: [.defaults, .prefersNavigationBarHidden(true)],
                animated: false
            )
        case .marketing:
            return window.present(
                Marketing(),
                options: [.defaults, .prefersNavigationBarHidden(true)],
                animated: false
            )
        case .onboardingChat:
            return window.present(Onboarding(), options: [.defaults], animated: false)
        case .offer:
            return window.present(
                Offer(),
                options: [.defaults, .prefersNavigationBarHidden(true)],
                animated: false
            )
        case .loggedIn:
            return window.present(
                LoggedIn(),
                options: [],
                animated: false
            )
        }
    }
}