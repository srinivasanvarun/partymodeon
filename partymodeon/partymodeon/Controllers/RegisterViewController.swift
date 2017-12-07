//
//  RegisterViewController.swift
//  partymodeon
//
//  Created by Varun Srinivasan on 10/24/17.
//  Copyright © 2017 Varun Srinivasan. All rights reserved.
//

import UIKit
class RegisterViewController: UIViewController {
    
    struct jsonresult: Decodable{
        let message: String
    }
    var succ = "Registration Successful!"
    @IBOutlet weak var firstnameField: UITextField!
    @IBOutlet weak var lastnameField: UITextField!
    @IBOutlet weak var monthField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var yearField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var occupationField: UITextField!
    @IBOutlet weak var msgLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func registerButtonAction(_ sender: Any) {
        let fn = firstnameField.text
        let ln = lastnameField.text
        let m = monthField.text
        let d = dateField.text
        let y = yearField.text
        let un = usernameField.text
        let p = passwordField.text
        let ph = NumberFormatter().number(from: phoneField.text!)!
        let ad = addressField.text
        let occ = occupationField.text
        register(fn: fn!, ln: ln!, m: m!, d: d!, y: y!, un: un!, p: p!, ph: Int(truncating: ph), ad: ad!, occ: occ!)
    }
    
    @IBAction func clearButtonAction(_ sender: Any) {
        firstnameField.text = ""
        lastnameField.text = ""
        monthField.text = ""
        dateField.text = ""
        yearField.text = ""
        usernameField.text = ""
        passwordField.text = ""
        phoneField.text = ""
        addressField.text = ""
        occupationField.text = ""
    }
    
    func register(fn:String,ln:String,m:String,d:String,y:String,un:String,p:String,ph:Int,ad:String,occ:String){
       // http://partymodeon.varuns.me/newuser
        let DOB:String = m+"/"+d+"/"+y
        let queue = DispatchQueue(label: "me.varuns.partymodeon")
        if usernameField.text != "" && passwordField.text != "" {
            let parameters = [    "userid": un,
                                  "password":p,
                                  "firstName":fn,
                                  "lastName":ln,
                                  "dob":DOB,
                                  "phone":ph,
                                  "address":ad,
                                  "occupation":occ] as [String : Any]
            guard let url = URL(string: "http://partymodeon.varuns.me/newuser") else { return }
            var request = URLRequest(url:url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
            request.httpBody = httpBody
            
            let session = URLSession.shared
            queue.async {
                session.dataTask(with: request) { (data,response,error) in
                    if let data = data {
                        do {
                            let jsonres = try JSONDecoder().decode(jsonresult.self, from:data)
                            if jsonres.message != self.succ {
                                DispatchQueue.main.async(execute: {
                                    self.displayAlert(alertTitle: "Registration failed", alertMessage: jsonres.message)
                                })
                            } else {
                                print("success")
                                DispatchQueue.main.async(execute: {
                                    self.displayAlert(alertTitle: "Success", alertMessage: jsonres.message)
                                })
                                // Insert segue to homepage here
                            }
                        } catch {
                            print(error)
                        }
                    }
                    }.resume()
            }
        } else {
            
        }
    }
    
    func displayAlert(alertTitle: String, alertMessage: String) {
        let alertController = UIAlertController(title: nil, message: alertMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Try again", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: false, completion: nil)
    }
    
}
