//
//  AppVVM.swift
//  VidaToDo
//
//  Created by Alexandre Laurin on 4/18/18.
//  Copyright © 2018 Vida Health. All rights reserved.
//

import UIKit

class AppViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard let initialViewController = SharedGlobalRouter.viewControllerForURLPath(GlobalURL.tab.routingPath) else {
            errorLog("Could not load initial view controller.")
            return
        }

        self.present(initialViewController, animated: false, completion: nil)
    }
}
