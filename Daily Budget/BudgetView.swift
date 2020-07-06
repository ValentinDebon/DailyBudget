//
//  BudgetView.swift
//  Daily Budget
//
//  Created by Valentin Debon on 03/07/2020.
//  Copyright © 2020 Valentin Debon. All rights reserved.
//

import SwiftUI

struct ExpensesView: View {
	@State private var isAddingExpense = false
	@ObservedObject var budget: Budget

    var body: some View {
		List {
			ForEach(budget.expenses) { expense in
				HStack {
					Text(expense.label)
					Spacer()
					Text(CurrencyFormatter.default.string(amount: expense.value))
				}
			}
		}
		.navigationBarTitle(budget.description)
		.navigationBarItems(trailing: Button(action: {
			self.isAddingExpense.toggle()
		}) {
			Image(systemName: "plus").imageScale(.large)
		}.sheet(isPresented: $isAddingExpense) {
			NewExpenseView(budget: self.budget)
		})
    }
}

struct BudgetView_Previews: PreviewProvider {
    static var previews: some View {
		ExpensesView(budget: Budget(dateInterval: DateInterval(), ceiling: 100))
    }
}
