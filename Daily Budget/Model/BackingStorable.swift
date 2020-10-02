//
//  BackingStorable.swift
//  Daily Budget
//
//  Created by Valentin Debon on 02/10/2020.
//  Copyright © 2020 Valentin Debon. All rights reserved.
//

import Foundation

protocol BackingStorable: AnyObject, Codable, Identifiable {
	static func makeFromBackingStorage(id: Self.ID) throws -> Self
	func saveToBackingStorage() throws
}

extension UUID {
	static let applicationSupportURL = try! FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)

	var resourceURL: URL {
		Self.applicationSupportURL.appendingPathComponent(self.uuidString)
	}
}

extension BackingStorable where Self.ID == UUID {
	static func makeFromBackingStorage(id: Self.ID) throws -> Self {
		try JSONDecoder().decode(Self.self, from: Data(contentsOf: id.resourceURL))
	}

	func saveToBackingStorage() throws {
		try JSONEncoder().encode(self).write(to: self.id.resourceURL)
	}
}
