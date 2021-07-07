//
//  Person.swift
//  NamesToFaces
//
//  Created by Igor Chernyshov on 07.07.2021.
//

import Foundation

class Person: NSObject {

	var name: String
	var image: String

	init(name: String, image: String) {
		self.name = name
		self.image = image
	}
}
