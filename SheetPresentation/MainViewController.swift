//
// MainViewController
// SheetPresentation
//
// Created by Eugene Egorov on 18 June 2020.
// Copyright (c) 2020 Eugene Egorov. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    private let stackView: UIStackView = .init()
    private let cardPresentationDelegate: SheetPresentationDelegate = .init(mode: .card(
        cornerRadius: 16, insets: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    ))
    private let flatSafePresentationDelegate: SheetPresentationDelegate = .init(mode: .flat(excludeSafeArea: true))
    private let flatFullPresentationDelegate: SheetPresentationDelegate = .init(mode: .flat(excludeSafeArea: false))

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Presentation"

        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        view.addSubview(stackView)

        let cardButton = UIButton(type: .system)
        cardButton.setTitle("Card", for: .normal)
        cardButton.addTarget(self, action: #selector(cardTap), for: .touchUpInside)
        stackView.addArrangedSubview(cardButton)

        let flatSafeButton = UIButton(type: .system)
        flatSafeButton.setTitle("Flat Safe", for: .normal)
        flatSafeButton.addTarget(self, action: #selector(flatSafeTap), for: .touchUpInside)
        stackView.addArrangedSubview(flatSafeButton)

        let flatFullButton = UIButton(type: .system)
        flatFullButton.setTitle("Flat Full", for: .normal)
        flatFullButton.addTarget(self, action: #selector(flatFullTap), for: .touchUpInside)
        stackView.addArrangedSubview(flatFullButton)

        let anchors = self.anchors
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: anchors.leading),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.bottomAnchor.constraint(equalTo: anchors.bottom),

            cardButton.heightAnchor.constraint(equalToConstant: 44),
            flatSafeButton.heightAnchor.constraint(equalToConstant: 44),
            flatFullButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }

    @objc private func cardTap() {
        let controller = ChildViewController()
        controller.modalPresentationStyle = .custom
        controller.transitioningDelegate = cardPresentationDelegate
        present(controller, animated: true)
    }

    @objc private func flatSafeTap() {
        let controller = ChildViewController()
        controller.modalPresentationStyle = .custom
        controller.transitioningDelegate = flatSafePresentationDelegate
        present(controller, animated: true)
    }

    @objc private func flatFullTap() {
        let controller = ChildViewController()
        controller.modalPresentationStyle = .custom
        controller.transitioningDelegate = flatFullPresentationDelegate
        present(controller, animated: true)
    }
}
