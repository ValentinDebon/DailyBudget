//
//  Migrations.swift
//  Daily Budget
//
//  Created by Valentin Debon on 24/02/2021.
//  Copyright © 2021 Valentin Debon. All rights reserved.
//

struct Migration {
	static let migrations : [Migration] = [
		Migration(queries: ["""
			create table budgets (
				id integer not null,
				start_date integer not null,
				end_date integer not null,
				ceiling real not null,
				label text,

				check (end_date > start_date),
				check (ceiling > 0.0),
				check (label is null or length(label) > 0),
				primary key (id)
			)
		""", """
			create table expenses (
				id integer not null,
				date integer not null,
				amount real not null,
				label text not null,

				check (amount > 0.0),
				check (length(label) > 0),
				primary key (id)
			)
		""", """
			create table budget_expenses (
				budget_id integer not null,
				expense_id integer not null,

				foreign key (budget_id) references budgets(id),
				foreign key (expense_id) references expenses(id),
				primary key (budget_id, expense_id)
			)
		""", """
			create trigger deleted_budget
				after delete on budgets for each row
			begin
				delete from budget_expenses where budget_id = old.id;
			end
		""", """
			create trigger deleted_budget_expenses
				after delete on budget_expenses for each row
			begin
				delete from expenses where id = old.expense_id;
			end
		"""]),
	]

	let queries: [StaticString]
}

