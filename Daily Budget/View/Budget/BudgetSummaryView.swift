//
//  BudgetSummaryView.swift
//  Daily Budget
//
//  Created by Valentin Debon on 03/07/2020.
//  Copyright © 2020 Valentin Debon. All rights reserved.
//

import Foundation
import SwiftUI

struct BudgetSummaryView: View {
	@EnvironmentObject private var budgetDAO : BudgetDAO
	var budget : Budget

	var body: some View {
		HStack {
			Text(budget.description)
			Spacer()
			ProgressView(progress: min(try! budgetDAO.totalExpenses(forBudget: self.budget) / self.budget.ceiling, 1.0))
		}
	}
}

fileprivate struct ProgressView: View {
	private static let lineWidth: CGFloat = 5
	private static let percentageFormatter: NumberFormatter = {
		let percentageFormatter = NumberFormatter()
		percentageFormatter.numberStyle = .percent
		return percentageFormatter
	}()

	@Environment(\.colorScheme) private var colorScheme
	let progress: Double

	var body: some View {
		ZStack {
			Circle()
				.stroke(lineWidth: Self.lineWidth)
				.opacity(0.2)
				.foregroundColor(colorScheme == .dark ? Color.white : Color.black)
			Circle()
				.trim(to: CGFloat(progress))
				.stroke(style: StrokeStyle(lineWidth: Self.lineWidth, lineCap: .round, lineJoin: .round))
				.foregroundColor(progressColor)
				.rotationEffect(.radians(3 * .pi / 2))
				.animation(.linear)

			Text(Self.percentageFormatter.string(from: NSNumber(value: self.progress)) ?? "?")
				.font(.caption)
				.bold()
			}.frame(width: 40, height: 40).padding()
	}

	private var progressColor: Color {
		Color(red: pow(progress, 3), green: 1.0 - pow(progress, 3), blue: 0)
	}
}
