//
//  Person.swift
//  NamesToFaces
//
//  Created by Igor Chernyshov on 07.07.2021.
//

import Foundation

class Person: NSObject, Codable { //, NSCoding {

	var name: String
	var image: String

	init(name: String, image: String) {
		self.name = name
		self.image = image
	}

//	required init(coder aDecoder: NSCoder) {
//		name = aDecoder.decodeObject(forKey: "name") as? String ?? ""
//		image = aDecoder.decodeObject(forKey: "image") as? String ?? ""
//	}
//
//	func encode(with aCoder: NSCoder) {
//		aCoder.encode(name, forKey: "name")
//		aCoder.encode(image, forKey: "image")
//	}
}
