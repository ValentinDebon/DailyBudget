//
//  BudgetSummaryView.swift
//  Daily Budget
//
//  Created by Valentin Debon on 03/07/2020.
//  Copyright © 2020 Valentin Debon. All rights reserved.
//

import SwiftUI

fileprivate struct ProgressView: View {
	@Environment(\.colorScheme) private var colorScheme
	let progress: Double
	let lineWidth: CGFloat = 5

	var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: lineWidth)
                .opacity(0.2)
				.foregroundColor(colorScheme == .dark ? Color.white : Color.black)
            Circle()
                .trim(to: CGFloat(progress))
                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                .foregroundColor(progressColor)
				.rotationEffect(.radians(3 * .pi / 2))
                .animation(.linear)

			Text("\(Int(progress * 100))%")
				.font(.caption)
				.bold()
			}.frame(width: 40, height: 40).padding()
	}

	private var progressColor: Color {
		Color(red: pow(progress, 3), green: 1.0 - pow(progress, 3), blue: 0)
	}
}

struct BudgetSummaryView: View {
	@ObservedObject var budget: Budget

	var body: some View {
		HStack {
			Text(budget.description)
			Spacer()
			ProgressView(progress: budget.progress)
		}
	}
}
