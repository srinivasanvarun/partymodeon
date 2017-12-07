//
//  MenuViewController.swift
//  partymodeon
//
//  Created by Varun Srinivasan on 11/15/17.
//  Copyright © 2017 Varun Srinivasan. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    let defaults = UserDefaults.standard
    @IBOutlet weak var welcomeLabel: UILabel!
    override func viewDidLoad() {
        let username = defaults.string(forKey: "username")
        welcomeLabel.text = "Hello "+username!+"!"
    }
    @IBAction func signOutAction(_ sender: Any) {
        defaults.removeObject(forKey:"username")
        if  defaults.string(forKey: "password") != nil {
            defaults.removeObject(forKey:"password")
        }
        self.performSegue(withIdentifier: "homeToLoginSegue", sender: self)
    }
}
