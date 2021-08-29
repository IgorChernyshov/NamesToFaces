//
//  ViewController.swift
//  NamesToFaces
//
//  Created by Igor Chernyshov on 06.07.2021.
//

import UIKit
import LocalAuthentication

final class ViewController: UICollectionViewController {

	// MARK: - Properties
	private var people: [Person] = []
	private var isAuthenticated: Bool = false {
		didSet {
			self.collectionView.reloadData()
			if isAuthenticated == true {
				navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
			}
		}
	}

	// MARK: - Lifecycle
	override func viewDidLoad() {
		super.viewDidLoad()
		title = "Names2Faces"
		navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Unlock", style: .done, target: self, action: #selector(unlockDidTap))

		if let savedPeople = UserDefaults.standard.object(forKey: "people") as? Data {
			do {
				people = try JSONDecoder().decode([Person].self, from: savedPeople)
			} catch {
				print("Failed to load people")
			}
			//		-= NSCoding =-
			//		if let decodedPeople = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedPeople) as? [Person] {
			//			people = decodedPeople
			//		}
		}
	}

	// MARK: - Actions
	@objc private func addNewPerson() {
		let picker = UIImagePickerController()
		picker.allowsEditing = true
		picker.delegate = self
		if UIImagePickerController.isSourceTypeAvailable(.camera) {
			picker.sourceType = .camera
		}
		present(picker, animated: true)
	}

	private func rename(person: Person) {
		let alertController = UIAlertController(title: "Rename person", message: nil, preferredStyle: .alert)
		alertController.addTextField()
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		alertController.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak alertController] _ in
			guard let newName = alertController?.textFields?.first?.text else { return }
			person.name = newName
			self?.collectionView.reloadData()
			self?.save()
		})
		present(alertController, animated: UIView.areAnimationsEnabled)
	}

	private func delete(person: Person) {
		let alertController = UIAlertController(title: "Delete person", message: "Are you sure want to delete this person?", preferredStyle: .alert)
		alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
		alertController.addAction(UIAlertAction(title: "OK", style: .destructive) { [weak self] _ in
			self?.people.removeAll { $0 == person }
			self?.collectionView.reloadData()
		})
		present(alertController, animated: UIView.areAnimationsEnabled)
	}

	// MARK: - Authentication
	@objc private func unlockDidTap() {
		let context = LAContext()
		var error: NSError?

		if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
			authenticateWithBiometry(context: context)
		} else {
			authenticateWithPassword()
		}
	}

	private func authenticateWithBiometry(context: LAContext) {
		let reason = "Identify yourself!"

		context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
			[weak self] success, authenticationError in

			DispatchQueue.main.async {
				if success {
					self?.isAuthenticated = true
				} else {
					let alertController = UIAlertController(title: "Authentication failed", message: "You could not be verified; please try again.", preferredStyle: .alert)
					alertController.addAction(UIAlertAction(title: "OK", style: .default))
					self?.present(alertController, animated: true)
				}
			}
		}
	}

	private func authenticateWithPassword() {
		let alertController = UIAlertController(title: "Biometry unavailable", message: "Enter a password.", preferredStyle: .alert)
		alertController.addTextField()
		alertController.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
			guard let password = alertController.textFields?.first?.text else { return }
			if let savedPassword = KeychainWrapper.standard.string(forKey: "Password") {
				if password == savedPassword {
					self?.isAuthenticated = true
				} else {
					let wrongPasswordAlert = UIAlertController(title: "Wrong password", message: nil, preferredStyle: .alert)
					wrongPasswordAlert.addAction(UIAlertAction(title: "OK", style: .default))
					self?.present(wrongPasswordAlert, animated: UIView.areAnimationsEnabled)
				}
			} else {
				KeychainWrapper.standard.set(password, forKey: "Password")
				self?.isAuthenticated = true
			}
		})
		self.present(alertController, animated: true)
	}

	// MARK: - Data Operations
	private func save() {
		if let savedData = try? JSONEncoder().encode(people) {
			UserDefaults.standard.set(savedData, forKey: "people")
		} else {
			print("Failed to save people.")
		}
		//	-= NSCoding =-
		//	if let savedData = try? NSKeyedArchiver.archivedData(withRootObject: people, requiringSecureCoding: false) {
		//		UserDefaults.standard.set(savedData, forKey: "people")
		//	}
	}
}

// MARK: - Collection View
extension ViewController {

	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		isAuthenticated ? people.count : 0
	}

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else {
			fatalError("Unable to dequeue PersonCell.")
		}

		let person = people[indexPath.item]

		cell.nameLabel.text = person.name

		let path = getDocumentsDirectory().appendingPathComponent(person.image)
		cell.imageView.image = UIImage(contentsOfFile: path.path)

		cell.imageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
		cell.imageView.layer.borderWidth = 2
		cell.imageView.layer.cornerRadius = 3
		cell.layer.cornerRadius = 7

		return cell
	}

	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let person = people[indexPath.item]

		let alertController = UIAlertController(title: "What would you like to do?", message: nil, preferredStyle: .actionSheet)
		alertController.addAction(UIAlertAction(title: "Rename person", style: .default) { [weak self] _ in
			self?.rename(person: person)
		})
		alertController.addAction(UIAlertAction(title: "Delete person", style: .default) { [weak self] _ in
			self?.delete(person: person)
		})
		present(alertController, animated: true)
	}
}

// MARK: - Image Picker
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
		guard let image = info[.editedImage] as? UIImage else { return }

		let imageName = UUID().uuidString
		let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)

		if let jpegData = image.jpegData(compressionQuality: 0.8) {
			try? jpegData.write(to: imagePath)
		}

		let person = Person(name: "Unknown", image: imageName)
		people.append(person)
		collectionView.reloadData()
		save()
		dismiss(animated: true)
	}

	private func getDocumentsDirectory() -> URL {
		let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		return paths[0]
	}
}
