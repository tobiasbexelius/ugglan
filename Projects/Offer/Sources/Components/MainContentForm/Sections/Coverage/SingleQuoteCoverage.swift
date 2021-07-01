import Flow
import Form
import Foundation
import Presentation
import UIKit
import hCore
import hCoreUI
import hGraphQL

struct SingleQuoteCoverage {
	let quote: GraphQL.QuoteBundleQuery.Data.QuoteBundle.Quote
}

extension SingleQuoteCoverage: Presentable {
	func materialize() -> (SectionView, Disposable) {
		let section = SectionView(headerView: nil, footerView: nil)
		section.dynamicStyle = .brandGrouped(separatorType: .none)

		let bag = DisposeBag()

		bag += section.append(
			MultilineLabel(
				value:
					"Hedvig's home insurance offers good coverage for your house, your stuff and your family even when you're travelling abroad.",
				style: .brand(.body(color: .secondary))
			)
			.insetted(UIEdgeInsets(inset: 15))
		)

		bag += section.append(
			PerilCollection(
				perilFragmentsSignal: .init(quote.perils.map { $0.fragments.perilFragment })
			)
			.insetted(UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15))
		)

		section.appendSpacing(.inbetween)

		bag += section.append(
			InsurableLimits(
				insurableLimitFragmentsSignal: .init(
					quote.insurableLimits.map { $0.fragments.insurableLimitFragment }
				)
			)
		)

		section.appendSpacing(.inbetween)

		bag += section.append(DocumentsSection(quote: quote))

		return (section, bag)
	}
}