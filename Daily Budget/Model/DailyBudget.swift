//
//  DailyBudget.swift
//  Daily Budget
//
//  Created by Valentin Debon on 03/07/2020.
//  Copyright © 2020 Valentin Debon. All rights reserved.
//

import Foundation
import Combine
import os.log

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
				os_log(.error, "Unable to open budget \(url.description): \(error.localizedDescription)")
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
						os_log(.info, "Removed budget '\(id.uuidString)'")
					} catch {
						os_log(.error, "Unable to remove budget '\(id.uuidString)': \(error.localizedDescription)")
					}
				}

				for budget in newBudgets where added.contains(budget.id) {
					do {
						try budget.saveToBackingStorage()
						os_log(.info, "Added budget '\(budget.id.uuidString)'")
					} catch {
						os_log(.error, "Unable to add budget '\(budget.id.uuidString)': \(error.localizedDescription)")
					}
				}
			}
		)
	}
}
