import Apollo
import Foundation
import hCore
import hGraphQL
import Offer
import TestingUtil

public extension JSONObject {
    static func makeSwedishApartment() -> JSONObject {
        GraphQL.QuoteBundleQuery.Data.init(
            quoteBundle: .init(
                quotes: [
                    .init(
                        id: "123",
                        currentInsurer: nil,
                        firstName: "Hedvig",
                        lastName: "Hedvigsen",
                        quoteDetails: GraphQL.QuoteBundleQuery.Data.QuoteBundle.Quote.QuoteDetail.makeSwedishApartmentQuoteDetails(
                            street: "Lilla gatan 12",
                            zipCode: "12345",
                            householdSize: 200,
                            livingSpace: 20,
                            swedishApartmentType: .rent
                        )
                    )
                ],
                bundleCost: .init(
                    monthlyGross: .init(amount: "100", currency: "SEK"),
                    monthlyDiscount: .init(amount: "100", currency: "SEK"),
                    monthlyNet: .init(amount: "100", currency: "SEK")
                )
            )
        ).jsonObject
    }
}
