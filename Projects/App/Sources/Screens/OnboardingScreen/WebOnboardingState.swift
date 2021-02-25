import Apollo
import Flow
import Foundation
import hCore
import hGraphQL
import UIKit
import WebKit

enum WebOnboardingScreen {
    case webOffer
    case webOnboarding
    
    var screen: ApplicationState.Screen {
        switch self {
        case .webOffer:
            return .webOffer
        case .webOnboarding:
            return .webOnboarding
        }
    }
}

struct WebOnboardingState {
    let screen: WebOnboardingScreen
    @ReadWriteState var offerIds: [String] = []
    
    private var locale: String {
        Localization.Locale.currentLocale.webPath
    }
    
    private var path: String {
        switch screen {
        case .webOffer:
            return "/\(locale)/new-member/offer"
        case .webOnboarding:
            return "\(locale)new-member"
        }
    }
    
    private var host: String {
        Environment.current.baseUrl
    }
    
    private var token: String? {
        guard let token = ApolloClient.retreiveToken() else {
            return nil
        }
        
        return token.urlEncodedString
    }
    
    private var queryItems: [URLQueryItem] {
        switch screen {
        case .webOffer:
            return [URLQueryItem(name: "quoteIds", value: "[" + offerIds.joined(separator: ",") + "]")]
        case .webOnboarding:
            return [URLQueryItem(name: "", value: "variation=ios")]
        }
    }
    
    private var fragment: String {
        return "#token=\(token ?? "")"
    }
    
    private var components: URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        components.path = path
        components.queryItems = queryItems
        return components
    }
    
    public var url: URL? {
        let url = components.url
        return URL(string: fragment, relativeTo: url)
    }
}