//
//  UIImageView+Ext.swift
//  picto
//
//  Created by Jay on 2024-07-14.
//

import Foundation
import UIKit
import Kingfisher

extension UIImageView {
    func setKfImage(url: String) {
        let url = URL(string: url)
        self.kf.setImage(with: url)
    }

    func setComplexImage(url: String, placeholder: UIImage) {
        print("Hello \(url)")
        let url = URL(string: url)
        let processor = DownsamplingImageProcessor(size: self.bounds.size)
                     |> RoundCornerImageProcessor(cornerRadius: 20)
        self.kf.indicatorType = .activity
        self.kf.setImage(
            with: url,
            placeholder: placeholder,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
            ])
        {
            result in
            switch result {
            case .success(let value):
                print("Task done for: \(value.source.url?.absoluteString ?? "")")
            case .failure(let error):
                print("Job failed: \(error.localizedDescription)")
                print("Failure: \(error)")
            }
        }
    }
}
