//
// ChildViewController
// SheetPresentation
//
// Created by Eugene Egorov on 18 June 2020.
// Copyright (c) 2020 Eugene Egorov. All rights reserved.
//

import UIKit

class ChildViewController: UIViewController {
    private let backgroundView: UIView = .init()
    private let label: UILabel = .init()
    private let closeButton: UIButton = .init(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear

        if #available(iOS 13.0, *) {
            backgroundView.backgroundColor = .systemGray6
        } else {
            backgroundView.backgroundColor = UIColor(white: 0.9, alpha: 1)
        }
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.clipsToBounds = true
        backgroundView.layer.cornerRadius = 16
        view.addSubview(backgroundView)

        label.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)

        closeButton.setTitle("Close", for: .normal)
        closeButton.addTarget(self, action: #selector(closeTap), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)

        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 500),

            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),

            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            closeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            closeButton.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 16),
            closeButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }

    @objc private func closeTap() {
        dismiss(animated: true)
    }
}
