//
// SheetPresentation
// SheetPresentation
//
// Created by Eugene Egorov on 18 June 2020.
// Copyright (c) 2020 Eugene Egorov. All rights reserved.
//

import UIKit

enum SheetPresentationMode {
    case flat(excludeSafeArea: Bool)
    case card(cornerRadius: CGFloat, insets: UIEdgeInsets)
}

class SheetPresentationController: UIPresentationController {
    private let mode: SheetPresentationMode
    private let defaultHeight: CGFloat = 200.0
    private let backgroundView: UIView = .init()

    init(mode: SheetPresentationMode, presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        self.mode = mode

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

        let insets: UIEdgeInsets
        switch mode {
        case .flat(let excludeSafeArea):
            insets = excludeSafeArea ? safeInsets : .zero
        case .card(_, let cardInsets):
            insets = UIEdgeInsets(
                top: max(cardInsets.top, safeInsets.top),
                left: cardInsets.left + safeInsets.left,
                bottom: max(cardInsets.bottom, safeInsets.bottom),
                right: cardInsets.right + safeInsets.right
            )
        }

        let bounds = containerView.bounds
        let width = bounds.width - insets.left - insets.right

        let frame: CGRect
        if let presentedView = presentedView {
            let fittingSize = CGSize(width: width, height: bounds.height - insets.top - insets.bottom)
            let fittedSize = presentedView.systemLayoutSizeFitting(
                fittingSize,
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            )
            let height = min(fittedSize.height, fittingSize.height)
            frame = CGRect(x: insets.left, y: bounds.height - fittedSize.height - insets.bottom, width: width, height: height)
        } else {
            frame = CGRect(x: insets.left, y: bounds.height - defaultHeight - insets.bottom, width: width, height: defaultHeight)
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

        switch mode {
        case .flat:
            break
        case .card(let cornerRadius, _):
            presentedView?.clipsToBounds = true
            presentedView?.layer.cornerRadius = cornerRadius
        }

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

        let reset = {
            let timings = UISpringTimingParameters(dampingRatio: 0.6, initialVelocity: CGVector(dx: 1, dy: 1))
            let animator = UIViewPropertyAnimator(duration: 0.6, timingParameters: timings)
            animator.addAnimations {
                presentedView.transform = .identity
            }
            animator.startAnimation()
        }

        switch recognizer.state {
        case .began:
            initialFrame = presentedView.frame
        case .changed:
            let y = translation.y * (translation.y >= 0 ? 1 : 0.3)
            let transform = CGAffineTransform(translationX: 0, y: y)
            presentedView.transform = transform
        case .ended:
            if (velocity.y > 0 && translation.y > initialFrame.height / 2) || velocity.y > 100 {
                presentedViewController.dismiss(animated: true, completion: nil)
            } else {
                reset()
            }
        case .cancelled:
            reset()
        case .failed:
            break
        default:
            break
        }
    }
}

class SheetPresentationDelegate: NSObject, UIViewControllerTransitioningDelegate {
    var mode: SheetPresentationMode

    init(mode: SheetPresentationMode) {
        self.mode = mode
    }

    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        SheetPresentationController(mode: mode, presentedViewController: presented, presenting: presenting)
    }

    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        SheetPresentationAnimationController(isPresenting: true)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        SheetPresentationAnimationController(isPresenting: false)
    }
}


class SheetPresentationAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
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
