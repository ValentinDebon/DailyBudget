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
	
	@State private var selectedTab = Tab.budgetsList
	@ObservedObject var dailyBudget: DailyBudget

    var body: some View {
		NavigationView {
			TabView(selection: $selectedTab) {
				List {
					ForEach(dailyBudget.budgets) { budget in
						NavigationLink(destination: ExpensesView(budget: budget)) {
							BudgetSummaryView(budget: budget)
						}
					}.onDelete {
						self.dailyBudget.budgets.remove(atOffsets: $0)
					}
				}
				.navigationBarTitle("Budgets List")
				.tag(Tab.budgetsList)
				.tabItem {
					Image(systemName: "coloncurrencysign.circle").imageScale(.large)
				}
				NewBudgetView(dailyBudget: self.dailyBudget, selectedTab: $selectedTab)
				.tag(Tab.newBudget)
				.tabItem {
					Image(systemName: "plus.circle.fill").imageScale(.large)
				}
			}.navigationBarTitle("Daily Budget")
		}
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
		ContentView(dailyBudget: DailyBudget())
    }
}
