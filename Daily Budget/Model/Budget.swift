//
//  Budget.swift
//  Daily Budget
//
//  Created by Valentin Debon on 23/02/2021.
//  Copyright © 2021 Valentin Debon. All rights reserved.
//

import Foundation

struct Budget: Codable, Identifiable, CustomStringConvertible {
	private enum CodingKeys: String, CodingKey {
		case id
		case startDate = "start_date"
		case endDate = "end_date"
		case ceiling
		case label
	}

	private static let dateFormatter : DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .long
		return dateFormatter
	}()

	let id : Int
	let interval : DateInterval
	let ceiling : Double
	let label : String?

	init(interval: DateInterval, ceiling: Double, label: String?) {
		self.id = Int.random(in: Int.min...Int.max)
		self.interval = interval
		self.ceiling = ceiling
		self.label = label
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		self.id = try container.decode(Int.self, forKey: .id)
		let startDate = try Date(timeIntervalSince1970: TimeInterval(container.decode(Int.self, forKey: .startDate)))
		let endDate = try Date(timeIntervalSince1970: TimeInterval(container.decode(Int.self, forKey: .endDate)))
		self.interval = DateInterval(start: startDate, end: endDate)
		self.ceiling = try container.decode(Double.self, forKey: .ceiling)
		self.label = try container.decodeIfPresent(String.self, forKey: .label)
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)

		try container.encode(self.id, forKey: .id)
		try container.encode(Int(self.interval.start.timeIntervalSince1970), forKey: .startDate)
		try container.encode(Int(self.interval.end.timeIntervalSince1970), forKey: .endDate)
		try container.encode(self.ceiling, forKey: .ceiling)
		try container.encodeIfPresent(self.label, forKey: .label)
	}

	var description : String {
		if let label = self.label {
			return label
		} else {
			return Self.dateFormatter.string(from: self.interval.start)
		}
	}
}
