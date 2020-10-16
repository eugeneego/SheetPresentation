//
// UIViewControllers
// SimpleSheetPresentation
//
// Created by Eugene Egorov on 18 June 2020.
// Copyright (c) 2020 Eugene Egorov. All rights reserved.
//

import UIKit

extension UIViewController {
    struct Anchors {
        var leading: NSLayoutXAxisAnchor
        var trailing: NSLayoutXAxisAnchor
        var top: NSLayoutYAxisAnchor
        var bottom: NSLayoutYAxisAnchor
    }

    var anchors: Anchors {
        if #available(iOS 11.0, *) {
            return Anchors(
                leading: view.safeAreaLayoutGuide.leadingAnchor,
                trailing: view.safeAreaLayoutGuide.trailingAnchor,
                top: view.safeAreaLayoutGuide.topAnchor,
                bottom: view.safeAreaLayoutGuide.bottomAnchor
            )
        } else {
            return Anchors(
                leading: view.leadingAnchor,
                trailing: view.trailingAnchor,
                top: topLayoutGuide.bottomAnchor,
                bottom: bottomLayoutGuide.topAnchor
            )
        }
    }
}

extension NSLayoutConstraint {
    func with(priority: UILayoutPriority) -> Self {
        self.priority = priority
        return self
    }
}
