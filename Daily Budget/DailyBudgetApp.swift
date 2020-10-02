//
//  DailyBudgetApp.swift
//  Daily Budget
//
//  Created by Valentin Debon on 02/10/2020.
//  Copyright © 2020 Valentin Debon. All rights reserved.
//

import SwiftUI

@main
struct DailyBudgetApp: App {
	@StateObject var dailyBudget = DailyBudget()

	var body: some Scene {
		WindowGroup {
			ContentView(dailyBudget: self.dailyBudget)
		}
	}
}
