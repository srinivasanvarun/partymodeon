//
//  ChangePasswordViewController.swift
//  partymodeon
//
//  Created by Varun Srinivasan on 11/16/17.
//  Copyright © 2017 Varun Srinivasan. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController {
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var repeatPasswordField: UITextField!
    
    struct jsonresult: Decodable{
        let message: String
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameField.text = UserDefaults.standard.string(forKey: "username")
    }
    
    @IBAction func submitButtonAction(_ sender: Any) {
        let queue = DispatchQueue(label: "me.varuns.partymodeon")
        let userid = UserDefaults.standard.string(forKey: "username")
        let pass = passwordField.text
        let reppass = repeatPasswordField.text
        queue.async {
            if pass==reppass{
                let parameters = ["userid": userid, "password": pass]
                guard let url = URL(string: "http://partymodeon.varuns.me/changepassword") else { return }
                var request = URLRequest(url:url)
                request.httpMethod = "POST"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
                request.httpBody = httpBody
                
                let session = URLSession.shared
                session.dataTask(with: request) { (data,response,error) in
                    if let data = data {
                        do {
                            let jsonres = try JSONDecoder().decode(jsonresult.self, from:data)
                            if jsonres.message != "Success" {
                                DispatchQueue.main.async(execute: {
                                    self.displayAlert(alertTitle: "Login failed", alertMessage: jsonres.message, action: "Try again")
                                })
                            } else {
                                print("success")
                                if UserDefaults.standard.string(forKey: "password") != nil {
                                    UserDefaults.standard.set(pass, forKey: "password")
                                }
                                DispatchQueue.main.async(execute: {
                                    self.displayAlert(alertTitle: "Success", alertMessage: "Password changed. Do remember your new password!!!", action: "Ok")
                                })
                            }
                        } catch {
                            print(error)
                        }
                        
                    }
                    }.resume()
            }else{
                DispatchQueue.main.async(execute: {
                    self.displayAlert(alertTitle: "Unable to save", alertMessage: "Passwords do not match", action: "Try again")
                })
            }
        }
    }
    
    @IBAction func clearAction(_ sender: Any) {
        passwordField.text = ""
        repeatPasswordField.text = ""
    }
    
    
    func displayAlert(alertTitle: String, alertMessage: String, action: String) {
        let alertController = UIAlertController(title: nil, message: alertMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title: action, style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: false, completion: nil)
    }
    
}
