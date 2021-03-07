//
//  ExpensesView.swift
//  Daily Budget
//
//  Created by Valentin Debon on 03/07/2020.
//  Copyright © 2020 Valentin Debon. All rights reserved.
//

import SwiftUI

struct ExpensesView: View {
	@Environment(\.colorScheme) private var colorScheme
	@State private var isAddingExpense = false
	@State private var editMode = EditMode.inactive
	@EnvironmentObject private var budgetDAO : BudgetDAO
	var budget : Budget

    var body: some View {
		VStack {
			List {
				ForEach(try! budgetDAO.readExpenses(forBudget: self.budget)) { expense in
					HStack {
						Text(expense.description)
						Spacer()
						Text(amount: expense.amount)
					}
				}
				.onDelete { offsets in
					try! self.budgetDAO.deleteExpenses(forBudget: self.budget, atOffsets: offsets)
				}
			}
			HStack {
				VStack(alignment: .trailing) {
					Text(amount: try! self.budgetDAO.totalExpenses(forBudget: self.budget))
						.bold()
						.font(.largeTitle)
					Text(amount: budget.ceiling)
						.bold()
						.font(.largeTitle)
				}
				Image(systemName: "plus.circle.fill").imageScale(.large)
			}
			.padding(20)
			.foregroundColor(colorScheme == .dark ? .black : .white)
			.background(RoundedRectangle(cornerRadius: 20).padding(5))
			.onTapGesture {
				self.isAddingExpense.toggle()
			}
		}
		.navigationBarTitle(budget.description)
		.navigationBarItems(trailing: EditButton()).environment(\.editMode, $editMode)
		.sheet(isPresented: $isAddingExpense) {
			NewExpenseView(budget: self.budget)
		}
    }
}
