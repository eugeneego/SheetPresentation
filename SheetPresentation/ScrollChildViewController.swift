//
// ScrollChildViewController
// SheetPresentation
//
// Created by Eugene Egorov on 15 October 2020.
// Copyright (c) 2020 Eugene Egorov. All rights reserved.
//

import UIKit

class ScrollChildViewController: UIViewController {
    private let backgroundView: UIView = .init()
    private let scrollView: UIScrollView = .init()
    private let stackView: UIStackView = .init()
    private let closeButton: UIButton = .init(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear

        if #available(iOS 13.0, *) {
            backgroundView.backgroundColor = .systemGray6
        } else {
            backgroundView.backgroundColor = UIColor(white: 0.9, alpha: 1)
        }

        backgroundView.clipsToBounds = true
        backgroundView.layer.cornerRadius = 16
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundView)

        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 16
        stackView.directionalLayoutMargins = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)

        (1 ... 5).forEach { i in
            let label = UILabel()
            label.text = "\(i). Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
            label.numberOfLines = 0
            label.font = .preferredFont(forTextStyle: .subheadline)
            stackView.addArrangedSubview(label)
        }

        closeButton.setTitle("Close", for: .normal)
        closeButton.addTarget(self, action: #selector(closeTap), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)

        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 500),

            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),

            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor).with(priority: .defaultLow),

            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            closeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            closeButton.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 16),
            closeButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
            closeButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }

    @objc private func closeTap() {
        dismiss(animated: true)
    }
}

extension ScrollChildViewController: SheetPresentable {
    public var sheetPresentableScrollView: UIScrollView? {
        scrollView
    }
}
