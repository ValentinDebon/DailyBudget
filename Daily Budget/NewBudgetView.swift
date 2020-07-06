//
//  NewBudgetView.swift
//  Daily Budget
//
//  Created by Valentin Debon on 03/07/2020.
//  Copyright © 2020 Valentin Debon. All rights reserved.
//

import SwiftUI

struct NewBudgetView: View {
	@State private var startDate = Date()
	@State private var endDate = Calendar.current.date(byAdding: DateComponents(month: 1), to: Date())!
	@State private var ceiling = 0.0
	@State private var label = ""
	@ObservedObject var dailyBudget: DailyBudget
	@Binding var selectedTab: ContentView.Tab

    var body: some View {
		Form {
			Section(header: Text("New Budget")) {
				DatePicker(selection: $startDate, displayedComponents: .date) {
					Text("Start Date")
				}
				DatePicker(selection: $endDate, displayedComponents: .date) {
					Text("End Date")
				}
				HStack {
					TextField("Ceiling", value: $ceiling, formatter: CurrencyFormatter.default)
					Text(CurrencyFormatter.default.string(amount: self.ceiling))
				}
				TextField("Label (Optional)", text: $label)
			}
			Button(action: {
				self.dailyBudget.budgets.append(Budget(dateInterval: DateInterval(start: self.startDate, end: self.endDate), ceiling: self.ceiling, label: self.label))
				self.selectedTab = .budgetsList
			}) {
				Text("Add")
			}.disabled(self.endDate < self.startDate || self.ceiling <= 0)
		}.navigationBarTitle("New Budget")
    }
}

struct NewBudgetView_Previews: PreviewProvider {
	@State private static var selectedTab = ContentView.Tab.newBudget
    static var previews: some View {
        NewBudgetView(dailyBudget: DailyBudget(), selectedTab: $selectedTab)
    }
}
