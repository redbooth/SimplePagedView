//
//  ViewController.swift
//  SimplePagedViewExample
//
//  Created by New User on 12/18/18.
//  Copyright © 2018 twof. All rights reserved.
//

import UIKit
import SimplePagedViewFramework

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let green = UIView()
        green.backgroundColor = .green

        let red = UIView()
        red.backgroundColor = .red

        let orange = UIView()
        orange.backgroundColor = .orange

        let pagedView = SimplePagedView(with: green, red, orange)
        pagedView.pageIndicatorIsInteractive = true

        self.add(pagedView) { (child) -> [NSLayoutConstraint] in
            return [
                child.topAnchor.constraint(equalTo: view.topAnchor),
                child.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                child.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                child.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ]
        }
    }

}

