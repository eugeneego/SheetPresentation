//
// MainViewController
// SimpleSheetPresentation
//
// Created by Eugene Egorov on 18 June 2020.
// Copyright (c) 2020 Eugene Egorov. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    private let presentButton: UIButton = .init(type: .system)
    private let presentationDelegate: SimpleSheetPresentationDelegate = .init()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Presentation"

        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }

        presentButton.setTitle("Present", for: .normal)
        presentButton.addTarget(self, action: #selector(presentTap), for: .touchUpInside)
        presentButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(presentButton)

        let anchors = self.anchors
        NSLayoutConstraint.activate([
            presentButton.leadingAnchor.constraint(equalTo: anchors.leading, constant: 16),
            presentButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            presentButton.bottomAnchor.constraint(equalTo: anchors.bottom, constant: -16),
            presentButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }

    @objc private func presentTap() {
        let controller = ChildViewController()
        controller.modalPresentationStyle = .custom
        controller.transitioningDelegate = presentationDelegate
        present(controller, animated: true)
    }
}
