//
//  EditProfileViewController.swift
//  partymodeon
//
//  Created by Varun Srinivasan on 11/16/17.
//  Copyright © 2017 Varun Srinivasan. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController {
    
    struct jsonresult: Decodable{
        let message: String
    }
    var succ = "Success"
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var firstNameField: UITextField!
    @IBOutlet weak var lastNameField: UITextField!
    @IBOutlet weak var monthField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var yearField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var occupationField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameField.text = UserDefaults.standard.string(forKey: "username")
    }
    
    @IBAction func submitAction(_ sender: Any) {
        var parameters = [:] as [String : Any]
        let fn = firstNameField.text
        let ln = lastNameField.text
        let m = monthField.text
        let d = dateField.text
        let y = yearField.text
        let a = addressField.text
        let o = occupationField.text
        let p = phoneField.text
        
        let queue = DispatchQueue(label: "me.varuns.partymodeon")
        queue.async {
            if fn != "" {
                parameters["firstName"] = fn
            }
            if ln != "" {
                parameters["lastName"] = ln
            }
            if m != "" && d != "" &&  y != "" {
                let datestring = m!+"/"+d!+"/"+y!
                let dateFormatterGet = DateFormatter()
                dateFormatterGet.dateFormat = "MM/dd/yyyy"
                
                if dateFormatterGet.date(from: datestring) != nil {
                    parameters["dob"] = datestring
                } else {
                    DispatchQueue.main.async(execute: {
                        self.displayAlert(alertTitle: "Error", alertMessage: "Error! DOB field not valid.", action: "Try again")
                    })
                }
            }
            if a != "" {
                parameters["address"] = a
            }
            if o != "" {
                parameters["occupation"] = o
            }
            if p != "" {
                parameters["phone"] = Int(p!)
            }
            if parameters.isEmpty != true {
                parameters["userid"] = UserDefaults.standard.string(forKey: "username")
                print(parameters)
                guard let url = URL(string: "http://partymodeon.varuns.me/edituser") else { return }
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
                                if jsonres.message != self.succ {
                                    DispatchQueue.main.async(execute: {
                                        self.displayAlert(alertTitle: "Error", alertMessage: jsonres.message, action: "Try again")
                                    })
                                } else {
                                    print("success")
                                    DispatchQueue.main.async(execute: {
                                        self.clearAction(self)
                                        self.displayAlert(alertTitle: "Success", alertMessage: "Changes saved successfully! Click back in the page to go back to main menu.", action: "OK")
                                    })
                                }
                            } catch {
                                print(error)
                            }
                        }
                        }.resume()
            } else {
                DispatchQueue.main.async(execute: {
                    self.displayAlert(alertTitle: "Error", alertMessage: "Error! No fields to update.", action: "Try again")
                })
            }
        }
    }
    
    @IBAction func clearAction(_ sender: Any) {
        firstNameField.text = ""
        lastNameField.text = ""
        monthField.text = ""
        dateField.text = ""
        yearField.text = ""
        addressField.text = ""
        occupationField.text = ""
        phoneField.text = ""
    }
    func displayAlert(alertTitle: String, alertMessage: String, action: String) {
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title: action, style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: false, completion: nil)
    }
}
