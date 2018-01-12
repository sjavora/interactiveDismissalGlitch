//
//  PartialPresentationController.swift
//  Shared
//
//  Created by Šimon Javora on 04/07/2017.
//  Copyright © 2017 skypicker. All rights reserved.
//

import UIKit

public protocol PartialPresentationControllerDelegate: class {
    func partialPresentationControllerDidDismiss(_ controller: PartialPresentationController)
}

public final class PartialPresentationController: UIPresentationController {

    @objc(PartialPresentationControllerMode)
    public enum Mode: Int {
        case left
        case right
        case bottom
        case center
    }
    
    public weak var partialPresentationDelegate: PartialPresentationControllerDelegate?

    public let mode: Mode

    private(set) lazy var containerViewPanRecognizer = UIPanGestureRecognizer()

    private lazy var dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap(recognizer:)))
        )

        return view
    }()
    
    override public var frameOfPresentedViewInContainerView: CGRect {
        
        guard let containerView = containerView else { return .zero }
        
        let containerBounds = containerView.bounds
        let size = presentedViewController.preferredContentSize

        switch mode {
            case .left:
                return CGRect(x: 0, y: 0, width: size.width, height: containerBounds.height)
            case .right:
                return CGRect(
                    x: containerBounds.width - size.width,
                    y: 0,
                    width: size.width,
                    height: containerBounds.height
                )
            case .bottom:
                
                let bottomPadding: CGFloat
                
                if #available(iOS 11.0, *) {
                        bottomPadding = containerView.safeAreaInsets.bottom
                } else {
                        bottomPadding = 0
                }
                return CGRect(
                    x: 0,
                    y: (containerBounds.height - size.height) - bottomPadding,
                    width: containerBounds.width,
                    height: size.height + bottomPadding
                )
            case .center:
                return CGRect(
                    x: (containerBounds.width - size.width) / 2,
                    y: (containerBounds.height - size.height) / 2,
                    width: size.width,
                    height: size.height
                )
        }
    }

    public var presentedViewConrnerRadius: CGFloat = 0

    public init(
        presentedViewController: UIViewController,
        presenting presentingViewController: UIViewController?,
        mode: Mode
    ) {
        self.mode = mode

        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
    
    override public func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        
        presentedView?.frame = frameOfPresentedViewInContainerView

        presentedView?.layer.cornerRadius = max(0, presentedViewConrnerRadius)
    }

    override public func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    override public func presentationTransitionWillBegin() {
        
        dimmingView.alpha = 0
        containerView?.insertSubview(dimmingView, at: 0)
        
        containerView?.addGestureRecognizer(self.containerViewPanRecognizer)
        
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        dimmingView.leadingAnchor.constraint(equalTo: dimmingView.superview!.leadingAnchor, constant: 0).isActive = true
        dimmingView.trailingAnchor.constraint(equalTo: dimmingView.superview!.trailingAnchor, constant: 0).isActive = true
        dimmingView.topAnchor.constraint(equalTo: dimmingView.superview!.topAnchor, constant: 0).isActive = true
        dimmingView.bottomAnchor.constraint(equalTo: dimmingView.superview!.bottomAnchor, constant: 0).isActive = true

        presentingViewController.transitionCoordinator?.animateAlongsideTransition(
            in: presentingViewController.view,
            animation: { _ in self.dimmingView.alpha = 0.3 }
        )
    }
    
    override public func dismissalTransitionWillBegin() {
        presentingViewController.transitionCoordinator?.animateAlongsideTransition(
            in: presentingViewController.view,
            animation: { _ in self.dimmingView.alpha = 0 }
        )
    }
    
    override public func dismissalTransitionDidEnd(_ completed: Bool) {
        
        if completed {
            dimmingView.removeFromSuperview()
        }
    }
    
    @objc private func handleBackgroundTap(recognizer: UITapGestureRecognizer) {
        presentingViewController.dismiss(animated: true) { [weak self] in
            if let strongSelf = self {
                strongSelf.partialPresentationDelegate?.partialPresentationControllerDidDismiss(strongSelf)
            }
        }
    }
}
