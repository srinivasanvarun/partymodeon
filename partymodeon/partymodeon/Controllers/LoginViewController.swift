//
//  LoginViewController.swift
//  partymodeon
//
//  Created by Varun Srinivasan on 10/24/17.
//  Copyright © 2017 Varun Srinivasan. All rights reserved.
//

import UIKit
class LoginViewController: UIViewController {
    var popup:UIView!
    
    struct jsonresult: Decodable{
        let message: String
    }
    var succ = "Success"
    var view1 = UIView()
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var msgLabel: UILabel!
    @IBOutlet weak var rememberMeSlide: UISwitch!
    let defaults = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func loginButtonAction(_ sender: Any) {
        let queue = DispatchQueue(label: "me.varuns.partymodeon")
        if usernameField.text != "" && passwordField.text != "" {
            if rememberMeSlide.isOn {
                defaults.set(passwordField.text, forKey: "password")
            }
            defaults.set(usernameField.text, forKey: "username")
            let parameters = ["userid":usernameField.text , "password":passwordField.text]
            guard let url = URL(string: "http://partymodeon.varuns.me/checkuser") else { return }
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
                                    self.displayAlert(alertTitle: "Login failed", alertMessage: jsonres.message)
                                })
                            } else {
                                print("success")
                                DispatchQueue.main.async(execute: {
                                    self.performSegue(withIdentifier: "loginToHomeSegue", sender: self)
                                })
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
    func initializeSpinner(xs: String){
        view1 = UIView(frame: CGRect(x:0, y:0, width:200, height:50))
        view1.backgroundColor = UIColor.gray
        view1.layer.cornerRadius = 10
        
        let wait = UIActivityIndicatorView(frame: CGRect(x:0,y:0,width:80,height:50))
        wait.color = UIColor.black
        wait.hidesWhenStopped = false
        wait.startAnimating()
        
        let text = UILabel(frame: CGRect(x:60, y:0, width:120, height:50))
        text.text = xs
        view1.addSubview(wait)
        view1.addSubview(text)
        view1.center = self.view.center
        view1.tag = 1000
    }
    
    func displayAlert(alertTitle: String, alertMessage: String) {
        let alertController = UIAlertController(title: nil, message: alertMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Try again", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: false, completion: nil)
    }
    
}
