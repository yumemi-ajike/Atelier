//
//  ViewController.swift
//  Atelier
//
//  Created by Atsushi Jike on 2019/12/02.
//  Copyright © 2019 Atsushi Jike. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    private let canvasView = CanvasView()

    override func viewDidLoad() {
        super.viewDidLoad()
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(canvasView)
        NSLayoutConstraint.activate([
            canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            canvasView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            canvasView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
    }


}

