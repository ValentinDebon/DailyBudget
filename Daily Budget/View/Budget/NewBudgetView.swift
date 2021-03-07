//
//  NewBudgetView.swift
//  Daily Budget
//
//  Created by Valentin Debon on 03/07/2020.
//  Copyright © 2020 Valentin Debon. All rights reserved.
//

import SwiftUI

struct NewBudgetView: View {
	private static let currencyFormatter = Text.currencyFormatter

	@EnvironmentObject private var budgetDAO : BudgetDAO
	@State private var startDate = Calendar.current.startOfDay(for: Date())
	@State private var endDate = Calendar.current.date(byAdding: DateComponents(month: 1),
													   to: Calendar.current.startOfDay(for: Date()))!
	@State private var ceiling = 0.0
	@State private var label = ""
	@Binding var selectedTab : ContentView.Tab

    var body: some View {
		Form {
			Section(header: Text("New Budget")) {
				DatePicker(selection: $startDate, displayedComponents: .date) {
					Text("Start Date")
				}
				DatePicker(selection: $endDate, displayedComponents: .date) {
					Text("End Date")
				}
				TextField("Ceiling", value: $ceiling, formatter: Self.currencyFormatter)
				TextField("Label (Optional)", text: $label)
			}
			Button(action: {
				try! self.budgetDAO.createBudget(budget: Budget(interval: DateInterval(start: self.startDate, end: self.endDate), ceiling: self.ceiling, label: self.label.isEmpty ? nil : self.label))
				self.selectedTab = .budgetsList
			}) {
				Text("Add")
			}.disabled(self.endDate <= self.startDate || self.ceiling <= 0)
		}.navigationBarTitle("New Budget")
    }
}

