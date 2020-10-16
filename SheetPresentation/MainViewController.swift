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
    private let cardPresentationDelegate: SheetPresentation = .init(mode: .card(
        cornerRadius: 16, insets: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    ))
    private let flatSafePresentationDelegate: SheetPresentation = .init(mode: .flat(excludeSafeArea: true))
    private let flatFullPresentationDelegate: SheetPresentation = .init(mode: .flat(excludeSafeArea: false))
    private let scrollFlatSafePresentationDelegate: SheetPresentation = .init(mode: .flat(excludeSafeArea: true))

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
        stackView.spacing = 8
        view.addSubview(stackView)

        stackView.addArrangedSubview(createButton(title: "Card", action: #selector(cardTap)))
        stackView.addArrangedSubview(createButton(title: "Flat Safe", action: #selector(flatSafeTap)))
        stackView.addArrangedSubview(createButton(title: "Flat Full", action: #selector(flatFullTap)))
        stackView.addArrangedSubview(createButton(title: "Scroll Flat Safe", action: #selector(scrollFlatSafeTap)))

        let anchors = self.anchors
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: anchors.leading),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.bottomAnchor.constraint(equalTo: anchors.bottom),
        ])
    }

    private func createButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.contentEdgeInsets = .init(top: 8, left: 16, bottom: 8, right: 16)
        return button
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

    @objc private func scrollFlatSafeTap() {
        let controller = ScrollChildViewController()
        controller.modalPresentationStyle = .custom
        controller.transitioningDelegate = scrollFlatSafePresentationDelegate
        present(controller, animated: true)
    }
}
