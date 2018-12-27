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

        let pagedView = SimplePagedView(
            indicatorColor: .purple,
            initialPage: 1,
            dotSize: 20,
            imageIndices: [-1: #imageLiteral(resourceName: "add")],
            with: [green, red, orange]
        )
        pagedView.pageIndicatorIsInteractive = true
        pagedView.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(pagedView)

        NSLayoutConstraint.activate([
            pagedView.topAnchor.constraint(equalTo: view.topAnchor),
            pagedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            pagedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pagedView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

