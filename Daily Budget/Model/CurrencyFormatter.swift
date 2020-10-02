//
//  CurrencyFormatter.swift
//  Daily Budget
//
//  Created by Valentin Debon on 02/10/2020.
//  Copyright © 2020 Valentin Debon. All rights reserved.
//

import Foundation

final class CurrencyFormatter: NumberFormatter {
	static let `default` = CurrencyFormatter()

	override init() {
		super.init()
		self.maximumFractionDigits = 2
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.maximumFractionDigits = 2
	}

	func string<T>(amount: T) -> String where T: BinaryFloatingPoint {
		guard let string = self.string(for: Double(amount)) else {
			return "Invalid amount"
		}

		if let currencySymbol = Locale.current.currencySymbol {
			return string + currencySymbol
		} else {
			return string
		}
	}
}
