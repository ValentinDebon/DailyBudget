//
//  Expenses.swift
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
	@ObservedObject var budget: Budget

    var body: some View {
		VStack {
			List {
				ForEach(budget.expenses) { expense in
					HStack {
						Text(expense.description)
						Spacer()
						Text(CurrencyFormatter.default.string(amount: expense.value))
					}
				}
				.onMove { offsets, offset in
					self.budget.expenses.move(fromOffsets: offsets, toOffset: offset)
				}
				.onDelete { offsets in
					self.budget.expenses.remove(atOffsets: offsets)
				}
			}
			HStack {
				VStack(alignment: .trailing) {
					Text(CurrencyFormatter.default.string(amount: budget.total))
					.bold()
					.font(.largeTitle)
					Text(CurrencyFormatter.default.string(amount: budget.ceiling))
					.bold()
					.font(.largeTitle)
				}
				Image(systemName: "plus.circle.fill").imageScale(.large)
			}
			.padding(15)
			.foregroundColor(colorScheme == .dark ? .black : .white)
			.background(RoundedRectangle(cornerRadius: 20))
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

struct ExpensesView_Previews: PreviewProvider {
    static var previews: some View {
		ExpensesView(budget: Budget(dateInterval: DateInterval(), ceiling: 100, label: "Preview"))
    }
}
