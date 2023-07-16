//
//  NewDiscoverVC.swift
//  Gala
//
//  Created by Jay on 2022-03-30.
//  Copyright © 2022 Warbly. All rights reserved.
//

import Foundation
import UIKit
import Combine

class NewDiscoverViewController: UIViewController {

    //private var viewModel = ViewModel

    private var cancellables = Set<AnyCancellable>()

    // private lazy var Search = {}
    private lazy var vStack: UIStackView = {

        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 10

        return stack
    }()

    private lazy var topCollectionView: UICollectionView = {
        let view = UICollectionView()
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    private lazy var catsCollectionView: UICollectionView = {
        let view = UICollectionView()
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()


    private lazy var lblBrowseCats: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false

        label.text = "Browse categories"
        label.textColor = .label

        return label
    }()

    override func viewDidLoad() {

        setupStyle()

    }

    private func setupStyle() {

        NSLayoutConstraint.activate([
            vStack.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            vStack.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            vStack.topAnchor.constraint(equalTo: view.topAnchor)
        ])

        vStack.addArrangedSubviews([
            //search,
            topCollectionView,
            lblBrowseCats,
            catsCollectionView
        ])

    }

}


// Mark: - Data Source

//extension NewDiscoverViewController: UICollectionViewDataSource {
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 0
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        return 
//    }
//
//
//}

// Mark: - Delegate

extension NewDiscoverViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected Item in collection view at \(indexPath)")
    }
}

/* A Cell for Item = Category Cell

 Number of Sections-> top collection view =L

 Cats - I */
