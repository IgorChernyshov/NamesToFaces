//
//  ViewController.swift
//  NamesToFaces
//
//  Created by Igor Chernyshov on 06.07.2021.
//

import UIKit

final class ViewController: UICollectionViewController {

	override func viewDidLoad() {
		super.viewDidLoad()

	}

	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 10
	}

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else {
			fatalError("Unable to dequeue PersonCell.")
		}
		return cell
	}
}

