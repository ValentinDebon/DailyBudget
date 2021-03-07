//
//  ContentView.swift
//  Daily Budget
//
//  Created by Valentin Debon on 03/07/2020.
//  Copyright © 2020 Valentin Debon. All rights reserved.
//

import SwiftUI

struct ContentView: View {
	enum Tab: Hashable {
		case budgetsList
		case newBudget
	}

	@EnvironmentObject private var budgetDAO: BudgetDAO
	@State private var selectedTab = Tab.budgetsList

    var body: some View {
		NavigationView {
			TabView(selection: $selectedTab) {
				List {
					ForEach(try! self.budgetDAO.readBudgets()) { budget in
						NavigationLink(destination: ExpensesView(budget: budget)) {
							BudgetSummaryView(budget: budget)
						}
					}.onDelete {
						try! self.budgetDAO.deleteBudgets(atOffsets: $0)
					}
				}
				.navigationBarTitle("Budgets List")
				.tag(Tab.budgetsList)
				.tabItem {
					Image(systemName: "coloncurrencysign.circle").imageScale(.large)
				}
				NewBudgetView(selectedTab: $selectedTab)
				.tag(Tab.newBudget)
				.tabItem {
					Image(systemName: "plus.circle.fill").imageScale(.large)
				}
			}.navigationBarTitle("Daily Budget")
		}
    }
}
