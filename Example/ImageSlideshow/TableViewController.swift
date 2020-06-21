//
//  TableViewController.swift
//  ImageSlideshow_Example
//
//  Created by Petr Zvoníček on 25.02.18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import ImageSlideshow

struct Model {
    let image: UIImage
    let title: String

    var inputSource: InputSource {
        return ImageSource(image: image)
    }
}

class TableViewController: UITableViewController {

    let models = [Model(image: UIImage(named: "img1")!, title: "First image"), Model(image: UIImage(named: "img2")!, title: "Second image"), Model(image: UIImage(named: "img3")!, title: "Third image"), Model(image: UIImage(named: "img4")!, title: "Fourth image")]

    var slideshowTransitioningDelegate: ZoomAnimatedTransitioningDelegate? = nil

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        let model = models[indexPath.row]
        cell.imageView?.image = model.image
        cell.textLabel?.text = model.title

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let fullScreenController = FullScreenSlideshowViewController()
        fullScreenController.inputs = models.map { $0.inputSource }
        fullScreenController.initialPage = indexPath.row

        if let cell = tableView.cellForRow(at: indexPath), let imageView = cell.imageView {
            slideshowTransitioningDelegate = ZoomAnimatedTransitioningDelegate(imageView: imageView, slideshowController: fullScreenController)
            fullScreenController.modalPresentationStyle = .custom
            fullScreenController.transitioningDelegate = slideshowTransitioningDelegate
        }

        fullScreenController.slideshow.currentPageChanged = { [weak self] page in
            if let cell = tableView.cellForRow(at: IndexPath(row: page, section: 0)), let imageView = cell.imageView {
                self?.slideshowTransitioningDelegate?.referenceImageView = imageView
            }
        }

        present(fullScreenController, animated: true, completion: nil)
    }
}
