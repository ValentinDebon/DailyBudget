//
//  Budget.swift
//  Daily Budget
//
//  Created by Valentin Debon on 02/10/2020.
//  Copyright © 2020 Valentin Debon. All rights reserved.
//

import Foundation
import Combine
import os.log

struct Expense: Identifiable, CustomStringConvertible, Codable {
	private static let dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .short
		return dateFormatter
	}()

	private(set) var id = UUID()
	let date: Date
	let label: String
	let value: Double

	var description: String {
		"\(Self.dateFormatter.string(from: self.date)) - \(self.label)"
	}
}

final class Budget: ObservableObject, BackingStorable {
	private enum CodingKeys: CodingKey {
		case id
		case total
		case expenses
		case dateInterval
		case ceiling
		case label
	}

	private static let dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .long
		return dateFormatter
	}()

	private var cancellables: Set<AnyCancellable>
	@Published private(set) var total: Double
	@Published var expenses: [Expense]
	let id: UUID
	let dateInterval: DateInterval
	let ceiling: Double
	let label: String

	init(dateInterval: DateInterval, ceiling: Double, label: String) {
		self.cancellables = []
		self.id = UUID()
		self.dateInterval = dateInterval
		self.ceiling = ceiling
		self.label = label
		self.expenses = []
		self.total = 0.0

		self.fillCancellables()
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		self.id = try container.decode(UUID.self, forKey: .id)
		self.total = try container.decode(Double.self, forKey: .total)
		self.expenses = try container.decode([Expense].self, forKey: .expenses)
		self.dateInterval = try container.decode(DateInterval.self, forKey: .dateInterval)
		self.ceiling = try container.decode(Double.self, forKey: .ceiling)
		self.label = try container.decode(String.self, forKey: .label)
		self.cancellables = []

		self.fillCancellables()
	}

	var description: String {
		self.label.isEmpty ? Self.dateFormatter.string(from: self.dateInterval.start) : self.label
	}

	var progress: Double {
		min(self.total / self.ceiling, 1.0)
	}

	private func fillCancellables() {
		self.cancellables.insert(
			self.$expenses.map {
				$0.map(\.value).reduce(0, +)
			}.assign(to: \.total, on: self)
		)
		self.cancellables.insert(
			self.$expenses.map {
				$0.map(\.value).reduce(0, +)
			}
			.sink { [weak self] _ in
				guard let self = self else {
					return
				}
				RunLoop.main.schedule(after: RunLoop.SchedulerTimeType(Date().advanced(by: 0.01)), tolerance: .microseconds(1), options: nil) {
					do {
						try self.saveToBackingStorage()
						os_log(.info, "Saved budget '\(self.id.uuidString)'")
					} catch {
						os_log(.error, "Unable to save budget '\(self.id.uuidString)': \(error.localizedDescription)")
					}
				}
			}
		)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		
		try container.encode(self.id, forKey: .id)
		try container.encode(self.total, forKey: .total)
		try container.encode(self.expenses, forKey: .expenses)
		try container.encode(self.dateInterval, forKey: .dateInterval)
		try container.encode(self.ceiling, forKey: .ceiling)
		try container.encode(self.label, forKey: .label)
	}
}
