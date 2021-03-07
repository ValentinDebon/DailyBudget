//
//  Expense.swift
//  Daily Budget
//
//  Created by Valentin Debon on 23/02/2021.
//  Copyright © 2021 Valentin Debon. All rights reserved.
//

import Foundation

struct Expense : Codable, Identifiable, CustomStringConvertible {
	private enum CodingKeys : String, CodingKey {
		case id
		case budgetId = "budget_id"
		case date
		case amount
		case label
	}

	private static let dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .short
		return dateFormatter
	}()

	let id : Int
	let budgetId : Int
	let date : Date
	let amount : Double
	let label : String

	init(budget: Budget, date: Date, amount: Double, label: String) {
		self.id = Int.random(in: Int.min...Int.max)
		self.budgetId = budget.id
		self.date = date
		self.amount = amount
		self.label = label
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		self.id = try container.decode(Int.self, forKey: .id)
		self.budgetId = try container.decode(Int.self, forKey: .budgetId)
		self.date = try Date(timeIntervalSince1970: TimeInterval(container.decode(Int.self, forKey: .date)))
		self.amount = try container.decode(Double.self, forKey: .amount)
		self.label = try container.decode(String.self, forKey: .label)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)

		try container.encode(self.id, forKey: .id)
		try container.encode(self.budgetId, forKey: .budgetId)
		try container.encode(Int(self.date.timeIntervalSince1970), forKey: .date)
		try container.encode(self.amount, forKey: .amount)
		try container.encode(self.label, forKey: .label)
	}

	var description: String {
		"\(Self.dateFormatter.string(from: self.date)) - \(self.label)"
	}
}
