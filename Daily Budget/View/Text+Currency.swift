//
//  Amount.swift
//  Daily Budget
//
//  Created by Valentin Debon on 24/02/2021.
//  Copyright © 2021 Valentin Debon. All rights reserved.
//

import SwiftUI

extension Text {
	static let currencyFormatter : NumberFormatter = {
		let currencyFormatter = NumberFormatter()
		currencyFormatter.maximumFractionDigits = 2
		currencyFormatter.numberStyle = .currency
		return currencyFormatter
	}()

	init(amount: Double) {
		self.init(Self.currencyFormatter.string(from: NSNumber(value: amount)) ?? "Invalid amount")
	}
}
