//
//  NewExpenseView.swift
//  Daily Budget
//
//  Created by Valentin Debon on 03/07/2020.
//  Copyright © 2020 Valentin Debon. All rights reserved.
//

import SwiftUI

struct NewExpenseView: View {
	@Environment(\.presentationMode) private var presentationMode
	@State private var date = Date()
	@State private var label = ""
	@State private var value = 0.0
	@ObservedObject var budget: Budget

	var body: some View {
		Form {
			Section(header: Text("New Expense")) {
				DatePicker(selection: $date, displayedComponents: .date) {
					Text("Date")
				}
				TextField("Label", text: $label)
				HStack {
					TextField("Amount", value: $value, formatter: CurrencyFormatter.default)
					Text(CurrencyFormatter.default.string(amount: self.value))
				}
			}
			Button(action: {
				self.budget.expenses.append(Expense(date: self.date, label: self.label, value: self.value))
				self.presentationMode.wrappedValue.dismiss()
			}) {
				Text("Add")
			}.disabled(!budget.dateInterval.contains(date) || label.isEmpty || value <= 0)
		}
	}
}

struct NewExpenseView_Previews: PreviewProvider {
    static var previews: some View {
		NewExpenseView(budget: Budget(dateInterval: DateInterval(), ceiling: 100, label: "Preview"))
    }
}
