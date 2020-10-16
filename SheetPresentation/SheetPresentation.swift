//
// SheetPresentation
// SheetPresentation
//
// Copyright (c) 2020 Eugene Egorov.
// License: MIT, https://github.com/eugeneego/SheetPresentation/blob/master/LICENSE
//

import UIKit

public protocol SheetPresentable {
    var sheetPresentableScrollView: UIScrollView? { get }
}

open class SheetPresentation: NSObject, UIViewControllerTransitioningDelegate {
    public enum Mode {
        case flat(excludeSafeArea: Bool)
        case card(cornerRadius: CGFloat, insets: UIEdgeInsets)
    }

    open var mode: Mode
    open var completion: (() -> Void)?

    public init(mode: Mode) {
        self.mode = mode
    }

    open func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        SheetPresentationController(mode: mode, presentedViewController: presented, presenting: presenting, completion: completion)
    }

    open func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        SheetPresentationAnimationController(isPresenting: true)
    }

    open func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        SheetPresentationAnimationController(isPresenting: false)
    }
}

open class SheetPresentationController: UIPresentationController {
    private let mode: SheetPresentation.Mode
    private let completion: (() -> Void)?

    private let backgroundView: UIView = .init()
    private let panGestureRecognizer: UIPanGestureRecognizer = .init()
    private let tapGestureRecognizer: UITapGestureRecognizer = .init()

    public init(
        mode: SheetPresentation.Mode,
        presentedViewController: UIViewController,
        presenting presentingViewController: UIViewController?,
        completion: (() -> Void)?
    ) {
        self.mode = mode
        self.completion = completion

        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)

        panGestureRecognizer.addTarget(self, action: #selector(panAction))
        panGestureRecognizer.delegate = self
        presentedViewController.view.addGestureRecognizer(panGestureRecognizer)

        tapGestureRecognizer.addTarget(self, action: #selector(close))
        backgroundView.addGestureRecognizer(tapGestureRecognizer)
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
    }

    deinit {
        scrollObserver?.invalidate()
    }

    open override var frameOfPresentedViewInContainerView: CGRect {
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
            observe(scrollView: presentable?.sheetPresentableScrollView)
            let fittingSize = CGSize(width: width, height: bounds.height - insets.top - insets.bottom)
            let fittedSize = presentedView.systemLayoutSizeFitting(
                fittingSize,
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            )
            let height = min(fittedSize.height, fittingSize.height)
            maxTopOffset = fittingSize.height - height
            frame = CGRect(x: insets.left, y: bounds.height - height - insets.bottom, width: width, height: height)
        } else {
            let height: CGFloat = 200
            frame = CGRect(x: insets.left, y: bounds.height - height - insets.bottom, width: width, height: height)
        }

        return frame
    }

    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(
            alongsideTransition: { _ in
                self.presentedView?.frame = self.frameOfPresentedViewInContainerView
            },
            completion: nil
        )
    }

    open override func presentationTransitionWillBegin() {
        guard let containerView = containerView, let coordinator = presentingViewController.transitionCoordinator else { return }

        switch mode {
        case .flat:
            break
        case .card(let cornerRadius, _):
            presentedView?.clipsToBounds = true
            presentedView?.layer.cornerRadius = cornerRadius
        }

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

    open override func dismissalTransitionWillBegin() {
        guard let coordinator = presentingViewController.transitionCoordinator else { return }

        coordinator.animate(
            alongsideTransition: { _ in
                self.backgroundView.alpha = 0
            },
            completion: nil
        )
    }

    open override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            backgroundView.removeFromSuperview()
            completion?()
        }
    }

    // MARK: - Pan gesture and scroll view handling

    private var initialFrame: CGRect = .zero
    private var interceptScroll: Bool = true
    private var maxTopOffset: CGFloat = 0
    private var scrollIsOnTop: Bool = true
    private var scrollObserver: NSKeyValueObservation?

    private var presentable: SheetPresentable? {
        presentedViewController as? SheetPresentable
    }

    @objc private func close() {
        presentedViewController.dismiss(animated: true, completion: nil)
    }

    @objc open func panAction(_ recognizer: UIPanGestureRecognizer) {
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
            let isScrollable = presentable?.sheetPresentableScrollView.map { $0.contentSize.height > $0.frame.height } ?? false
            interceptScroll = !isScrollable || (scrollIsOnTop && velocity.y > 0)
        case .changed:
            if interceptScroll {
                let y = max(translation.y * (translation.y >= 0 ? 1 : 0.3), -maxTopOffset)
                let transform = CGAffineTransform(translationX: 0, y: y)
                presentedView.transform = transform
            }
        case .ended:
            if interceptScroll {
                if (velocity.y > 0 && translation.y > initialFrame.height / 2) || velocity.y > 100 {
                    close()
                } else {
                    reset()
                }
            }
        case .cancelled:
            if interceptScroll {
                reset()
            }
        case .failed:
            break
        default:
            break
        }
    }

    private func observe(scrollView: UIScrollView?) {
        scrollObserver?.invalidate()
        scrollIsOnTop = scrollView?.contentOffset.y == 0
        scrollObserver = scrollView?.observe(\.contentOffset, options: .new) { [weak self] scrollView, change in
            guard self?.containerView != nil else { return }
            self?.onScroll(scrollView: scrollView, change: change)
        }
    }

    private func onScroll(scrollView: UIScrollView, change: NSKeyValueObservedChange<CGPoint>) {
        guard !presentedViewController.isBeingDismissed, !presentedViewController.isBeingPresented else { return }
        scrollIsOnTop = change.newValue?.y == 0
        if interceptScroll {
            stopScroll()
        }
    }

    private func stopScroll() {
        guard let scrollView = presentable?.sheetPresentableScrollView else { return }
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        scrollView.showsVerticalScrollIndicator = false
    }
}

extension SheetPresentationController: UIGestureRecognizerDelegate {
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        false
    }

    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        otherGestureRecognizer.view == presentable?.sheetPresentableScrollView
    }
}

open class SheetPresentationAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    public let isPresenting: Bool

    public init(isPresenting: Bool) {
        self.isPresenting = isPresenting
    }

    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
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

    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        isPresenting ? 0.6 : 0.2
    }
}
