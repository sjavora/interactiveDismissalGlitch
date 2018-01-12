//
//  PartialTransitionDelegate.swift
//  Shared
//
//  Created by Šimon Javora on 23/08/2017.
//  Copyright © 2017 Kiwi.com. All rights reserved.
//

import UIKit

public final class PartialTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {

    private weak var anchorView: UIView?
    private var interactiveTransitionController: UIPercentDrivenInteractiveTransition?
    private weak var presentingViewController: UIViewController?

    public func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        return ScreenEdgeSlideAnimator(
            action: .presenting,
            direction: .bottom,
            interactive: interactiveTransitionInProgress
        )
    }

    public func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        return ScreenEdgeSlideAnimator(
            action: .dismissing,
            direction: .bottom,
            interactive: interactiveTransitionInProgress
        )
    }

    public func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController
    ) -> UIPresentationController? {
        
        presentingViewController = presenting ?? source

        let partialPresentationController = PartialPresentationController(
            presentedViewController: presented,
            presenting: presenting,
            mode: .bottom
        )

        partialPresentationController.containerViewPanRecognizer.addTarget(
            self,
            action: #selector(handleContainerViewPan(recognizer:))
        )

        return partialPresentationController
    }

    public func interactionControllerForDismissal(
        using animator: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        return interactiveTransitionController
    }

    @objc private func handleContainerViewPan(recognizer: UIPanGestureRecognizer) {

        guard let view = recognizer.view else { return }

        switch recognizer.state {
            case .began:

                interactiveTransitionController = UIPercentDrivenInteractiveTransition()
                presentingViewController?.dismiss(animated: true, completion: nil)

            case .changed:

                let translation = recognizer.translation(in: view)
                let percentComplete = translation.y / view.bounds.height
                interactiveTransitionController?.update(percentComplete)

            case .failed, .ended, .cancelled:

                if recognizer.velocity(in: view).y > 0 {
                    interactiveTransitionController?.finish()
                } else {
                    interactiveTransitionController?.cancel()
                }
                
                interactiveTransitionController = nil
                
            default:
                break
        }
    }

    private var interactiveTransitionInProgress: Bool {
        return interactiveTransitionController != nil
    }
}
