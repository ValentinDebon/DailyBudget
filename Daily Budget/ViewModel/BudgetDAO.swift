//
//  BudgetDAO.swift
//  Daily Budget
//
//  Created by Valentin Debon on 23/02/2021.
//  Copyright © 2021 Valentin Debon. All rights reserved.
//

import Foundation
import SQLCodable
import SQLiteCodable

final class BudgetDAO: SQLDataAccessObject, ObservableObject {
	var database : SQLDatabase

	init(database: SQLDatabase) {
		self.database = database
	}

	/* Budgets CRUD methods & utils */

	func createBudget(budget: Budget) throws {
		self.objectWillChange.send()
		return try self.query("insert into budgets values (:id, :start_date, :end_date, :ceiling, :label)", with: budget).next()
	}

	func readBudgets() throws -> [Budget] {
		try Array(self.query("select * from budgets order by start_date desc"))
	}

	func deleteBudgets(atOffsets offsets: IndexSet) throws {
		self.objectWillChange.send()
		for index in offsets.reversed() {
			try self.query("delete from budgets order by start_date desc limit 1 offset ?1", with: index).next()
		}
	}

	func totalExpenses(forBudget budget: Budget) throws -> Double {
		try self.query("select sum(expenses.amount) from budget_expenses, expenses where budget_expenses.expense_id = expenses.id and budget_expenses.budget_id = ?1", with: budget.id).next() ?? 0.0
	}

	/* Expenses CRUD methods & utils */

	func createExpense(forBudget budget: Budget, expense: Expense) throws {
		self.objectWillChange.send()
		try self.query("insert into budget_expenses values (?1, ?2)", with: budget.id, expense.id).next()
		try self.query("insert into expenses values (:id, :date, :amount, :label)", with: expense).next()
	}

	func readExpenses(forBudget budget: Budget) throws -> [Expense] {
		try Array(self.query("select * from budget_expenses, expenses where budget_expenses.budget_id = ?1 and budget_expenses.expense_id = expenses.id order by date desc", with: budget.id))
	}

	func deleteExpenses(forBudget budget: Budget, atOffsets offsets: IndexSet) throws {
		self.objectWillChange.send()
		for index in offsets.reversed() {
			try self.query("delete from budget_expenses where expense_id = (select id from budget_expenses, expenses where budget_expenses.budget_id = ?1 and budget_expenses.expense_id = expenses.id order by date desc limit 1 offset ?2)", with: budget.id, index).next()
		}
	}
}
