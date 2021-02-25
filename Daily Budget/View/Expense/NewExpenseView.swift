//
//  NewExpenseView.swift
//  Daily Budget
//
//  Created by Valentin Debon on 03/07/2020.
//  Copyright © 2020 Valentin Debon. All rights reserved.
//

import SwiftUI

struct NewExpenseView: View {
	private static let currencyFormatter = Text.currencyFormatter

	@Environment(\.presentationMode) private var presentationMode
	@EnvironmentObject private var budgetDAO : BudgetDAO
	@State private var date = Date()
	@State private var amount = 0.0
	@State private var label = ""
	var budget : Budget

	var body: some View {
		Form {
			Section(header: Text("New Expense")) {
				DatePicker(selection: $date, displayedComponents: .date) {
					Text("Date")
				}
				TextField("Label", text: $label)
				TextField("Amount", value: $amount, formatter: Self.currencyFormatter)
			}
			Button(action: {
				try! self.budgetDAO.createExpense(forBudget: self.budget, expense: Expense(date: self.date, amount: self.amount, label: self.label))
				self.presentationMode.wrappedValue.dismiss()
			}) {
				Text("Add")
			}.disabled(!budget.interval.contains(date) || label.isEmpty || amount <= 0)
		}
	}
}

struct NewExpenseView_Previews: PreviewProvider {
    static var previews: some View {
		NewExpenseView(budget: Budget(interval: DateInterval(), ceiling: 100, label: "Preview"))
    }
}
