//
//  DailyBudgetApp.swift
//  Daily Budget
//
//  Created by Valentin Debon on 02/10/2020.
//  Copyright © 2020 Valentin Debon. All rights reserved.
//

import SwiftUI
import SQLiteCodable

private func makeDatabase() -> SQLiteDatabase {
	let fileManager = FileManager.default
	let applicationSupportURL = try! fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
	let databasePath = applicationSupportURL.appendingPathComponent("daily_budget.db").path
	let migrate = !fileManager.fileExists(atPath: databasePath)
	let sqliteDatabase = try! SQLiteDatabase(filename: databasePath)

	if migrate {
		for migration in Migration.migrations {
			for query in migration.queries {
				let migrationStatement = sqliteDatabase.statement(query)

				try! migrationStatement.reset()
				try! migrationStatement.nextRow()
			}
			sqliteDatabase.removePreparedStatements()
		}
	}

	return sqliteDatabase
}

@main
struct DailyBudgetApp: App {
	@StateObject var budgetDAO = BudgetDAO(database: makeDatabase())

	var body: some Scene {
		WindowGroup {
			ContentView().environmentObject(self.budgetDAO)
		}
	}
}
