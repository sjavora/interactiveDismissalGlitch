//
//  ViewController.swift
//  InteractiveModal
//
//  Created by Robert Chen on 1/6/16.
//  Copyright © 2016 Thorn Technologies. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let transitioningDelegateStorage = PartialTransitionDelegate()

    override func viewDidLoad() {
        super.viewDidLoad()

        transitioningDelegate = transitioningDelegateStorage
        modalPresentationStyle = .custom
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segue.destination.transitioningDelegate = transitioningDelegateStorage
        segue.destination.modalPresentationStyle = .custom
    }
}
