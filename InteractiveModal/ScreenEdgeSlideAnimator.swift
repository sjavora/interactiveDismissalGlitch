//
//  ScreenEdgeSlideAnimator.swift
//  Shared
//
//  Created by Šimon Javora on 03/08/2017.
//  Copyright © 2017 Kiwi.com. All rights reserved.
//

import UIKit

public final class ScreenEdgeSlideAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    public enum Direction {
        case left
        case right
        case top
        case bottom
    }

    public enum Action {
        case presenting
        case dismissing
    }

    private let action: Action
    private let direction: Direction
    private let interactive: Bool

    public init(action: Action, direction: Direction, interactive: Bool) {
        self.action = action
        self.direction = direction
        self.interactive = interactive
    }

    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView

        let fromViewKey: UITransitionContextViewKey = action == .presenting ? .from : .to
        let toViewKey: UITransitionContextViewKey = action == .presenting ? .to : .from

        let fromViewControllerKey: UITransitionContextViewControllerKey = action == .presenting ? .from : .to
        let toViewControllerKey: UITransitionContextViewControllerKey = action == .presenting ? .to : .from

        let fromViewController = transitionContext.viewController(forKey: fromViewControllerKey)
        let toViewController = transitionContext.viewController(forKey: toViewControllerKey)
        let fromView = transitionContext.view(forKey: fromViewKey)
        let toView = transitionContext.view(forKey: toViewKey)

        let onscreenTransform = CGAffineTransform.identity
        let offscreenTransform: CGAffineTransform

        switch direction {
            case .left:
                offscreenTransform = CGAffineTransform(translationX: -containerView.bounds.width, y: 0)
            case .right:
                offscreenTransform = CGAffineTransform(translationX: containerView.bounds.width, y: 0)
            case .top:
                offscreenTransform = CGAffineTransform(translationX: 0, y: -containerView.bounds.height)
            case .bottom:
                offscreenTransform = CGAffineTransform(translationX: 0, y: containerView.bounds.height)
        }

        let transitionDuration = self.transitionDuration(using: transitionContext)

        let startTransform = action == .presenting ? offscreenTransform : onscreenTransform
        let endTransform = action == .presenting ? onscreenTransform : offscreenTransform

        fromView.map { containerView.addSubview($0) }
        toView.map { containerView.addSubview($0) }

        toView?.transform = startTransform

        let animationOptions: UIViewAnimationOptions = interactive ? .curveLinear : .curveEaseInOut

        UIView.animate(withDuration: transitionDuration, delay: 0, options: animationOptions, animations: {
            toView?.transform = endTransform

            fromViewController?.setNeedsStatusBarAppearanceUpdate()
            toViewController?.setNeedsStatusBarAppearanceUpdate()
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }

    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
}
