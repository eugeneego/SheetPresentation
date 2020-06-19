//
// SimpleSheetPresentation
// SimpleSheetPresentation
//
// Created by Eugene Egorov on 18 June 2020.
// Copyright (c) 2020 Eugene Egorov. All rights reserved.
//

import UIKit

class SimpleSheetPresentationController: UIPresentationController {
    private let backgroundView: UIView = .init()
    private let defaultHeight: CGFloat = 200.0

    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)

        presentedViewController.view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panAction)))
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeAction)))
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }

        let safeInsets: UIEdgeInsets
        if #available(iOS 11.0, *) {
            safeInsets = containerView.safeAreaInsets
        } else {
            safeInsets = .zero
        }
        let bounds = containerView.bounds
        let inset: CGFloat = 16
        let xInset: CGFloat = inset + max(safeInsets.left, safeInsets.right)
        let width = bounds.width - xInset - xInset
        let bottomInset = max(safeInsets.bottom, inset)

        let frame: CGRect
        if let presentedView = presentedView {
            let fittingSize = CGSize(width: width, height: bounds.height - safeInsets.top - safeInsets.bottom)
            let fittedSize = presentedView.systemLayoutSizeFitting(
                fittingSize,
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            )
            let height = min(fittedSize.height, fittingSize.height)
            frame = CGRect(x: xInset, y: bounds.height - fittedSize.height - bottomInset, width: width, height: height)
        } else {
            frame = CGRect(x: xInset, y: bounds.height - defaultHeight - bottomInset, width: width, height: defaultHeight)
        }

        return frame
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(
            alongsideTransition: { _ in
                self.presentedView?.frame = self.frameOfPresentedViewInContainerView
            },
            completion: nil
        )
    }

    override func presentationTransitionWillBegin() {
        guard let containerView = containerView, let coordinator = presentingViewController.transitionCoordinator else { return }

        presentedView?.clipsToBounds = true
        presentedView?.layer.cornerRadius = 16

        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        backgroundView.alpha = 0
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundView.frame = containerView.bounds
        containerView.addSubview(backgroundView)

        coordinator.animate(
            alongsideTransition: { _ in
                self.backgroundView.alpha = 1
            },
            completion: nil
        )
    }

    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentingViewController.transitionCoordinator else { return }

        coordinator.animate(
            alongsideTransition: { _ in
                self.backgroundView.alpha = 0
            },
            completion: nil
        )
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            backgroundView.removeFromSuperview()
        }
    }

    // MARK: - Gestures

    @objc private func closeAction() {
        presentedViewController.dismiss(animated: true, completion: nil)
    }

    private var initialFrame: CGRect = .zero

    @objc private func panAction(_ recognizer: UIPanGestureRecognizer) {
        guard let presentedView = presentedView, let containerView = containerView else { return }

        let translation = recognizer.translation(in: containerView)
        let velocity = recognizer.velocity(in: containerView)

        let animate = { (frame: CGRect) in
            let timings = UISpringTimingParameters(dampingRatio: 0.6, initialVelocity: CGVector(dx: 1, dy: 1))
            let animator = UIViewPropertyAnimator(duration: 0.6, timingParameters: timings)
            animator.addAnimations {
                presentedView.frame = frame
            }
            animator.startAnimation()
        }

        switch recognizer.state {
        case .began:
            initialFrame = presentedView.frame
        case .changed:
            let frame = initialFrame.offsetBy(dx: 0, dy: translation.y)
            presentedView.frame = frame
        case .ended:
            if (velocity.y > 0 && translation.y > initialFrame.height / 2) || velocity.y > 100 {
                presentedViewController.dismiss(animated: true, completion: nil)
            } else {
                animate(initialFrame)
            }
        case .cancelled:
            animate(initialFrame)
        case .failed:
            break
        default:
            break
        }
    }
}

class SimpleSheetPresentationDelegate: NSObject, UIViewControllerTransitioningDelegate {
    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        SimpleSheetPresentationController(presentedViewController: presented, presenting: presenting)
    }

    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        SimpleSheetPresentationAnimationController(isPresenting: true)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        SimpleSheetPresentationAnimationController(isPresenting: false)
    }
}


class SimpleSheetPresentationAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    let isPresenting: Bool

    init(isPresenting: Bool) {
        self.isPresenting = isPresenting
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let viewController = transitionContext.viewController(forKey: isPresenting ? .to : .from) else { return }

        let containerView = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: viewController)
        let targetFrame: CGRect
        let timings: UITimingCurveProvider

        if isPresenting {
            containerView.addSubview(viewController.view)
            viewController.view.frame = finalFrame
            viewController.view.frame.origin.y = containerView.bounds.maxY
            targetFrame = finalFrame
            timings = UISpringTimingParameters(dampingRatio: 0.6, initialVelocity: CGVector(dx: 1, dy: 1))
        } else {
            targetFrame = CGRect(x: finalFrame.minX, y: containerView.bounds.maxY, width: finalFrame.width, height: finalFrame.height)
            timings = UICubicTimingParameters(animationCurve: .easeOut)
        }

        let animator = UIViewPropertyAnimator(duration: transitionDuration(using: transitionContext), timingParameters: timings)
        animator.addAnimations {
            viewController.view.frame = targetFrame
        }
        animator.addCompletion { position in
            if position == .end {
                transitionContext.completeTransition(true)
            }
        }
        animator.startAnimation()
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        isPresenting ? 0.6 : 0.2
    }
}
