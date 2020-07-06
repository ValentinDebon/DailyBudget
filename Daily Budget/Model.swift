//
//  Model.swift
//  Daily Budget
//
//  Created by Valentin Debon on 03/07/2020.
//  Copyright © 2020 Valentin Debon. All rights reserved.
//

import Foundation
import Combine
import os

extension UUID {
	static let applicationSupportURL = try! FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)

	var resourceURL: URL {
		Self.applicationSupportURL.appendingPathComponent(self.uuidString)
	}
}

extension ObservableObject where Self: Codable & Identifiable, Self.ID == UUID {
	static func makeFromBackingStorage(id: UUID) throws -> Self {
		try JSONDecoder().decode(Self.self, from: Data(contentsOf: id.resourceURL))
	}

	func saveToBackingStorage() throws {
		try JSONEncoder().encode(self).write(to: self.id.resourceURL)
	}
}

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
		guard let string = self.string(for: NSNumber(floatLiteral: Double(amount))) else {
			return "Invalid amount"
		}

		return "\(string)€"
	}
}

struct Expense: Identifiable, CustomStringConvertible, Codable {
	private static let dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .short
		return dateFormatter
	}()

	let id = UUID()
	let date: Date
	let label: String
	let value: Double

	var description: String {
		"\(Self.dateFormatter.string(from: self.date)) - \(self.label)"
	}
}

final class Budget: Identifiable, CustomStringConvertible, Codable, ObservableObject {
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
						os_log(.info, "Saved budget '%s'", self.id.uuidString)
					} catch {
						os_log(.error, "Unable to save budget '%s': %s", self.id.uuidString, error.localizedDescription)
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

final class DailyBudget: ObservableObject {
	private var cancellables: Set<AnyCancellable>
	@Published var budgets: [Budget] = []

	init() {
		self.budgets = []
		self.cancellables = []

		for url in try! FileManager.default.contentsOfDirectory(at: UUID.applicationSupportURL,
																includingPropertiesForKeys: nil) {
			do {
				guard let uuid = UUID(uuidString: url.lastPathComponent) else {
					continue
				}
				try self.budgets.append(Budget.makeFromBackingStorage(id: uuid))
			} catch {
				os_log(.error, "Unable to open budget %s: %s", url.description, error.localizedDescription)
			}
		}

		self.budgets.sort { $0.dateInterval.start < $1.dateInterval.start }

		self.cancellables.insert(
			self.$budgets.sink { [weak self] newBudgets in
				guard let self = self else {
					return
				}

				let oldIds = Set(self.budgets.lazy.map(\.id))
				let newIds = Set(newBudgets.lazy.map(\.id))
				let removed = oldIds.subtracting(newIds)
				let added = newIds.subtracting(oldIds)

				for id in removed {
					do {
						try FileManager.default.removeItem(at: id.resourceURL)
						os_log(.info, "Removed budget '%s'", id.uuidString)
					} catch {
						os_log(.error, "Unable to remove budget '%s': %s", id.uuidString, error.localizedDescription)
					}
				}

				for budget in newBudgets where added.contains(budget.id) {
					do {
						try budget.saveToBackingStorage()
						os_log(.info, "Added budget '%s'", budget.id.uuidString)
					} catch {
						os_log(.error, "Unable to add budget '%s': %s", budget.id.uuidString, error.localizedDescription)
					}
				}
			}
		)
	}
}
