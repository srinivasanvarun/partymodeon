//
//  ViewController.swift
//  partymodeon
//
//  Created by Varun Srinivasan on 10/23/17.
//  Copyright © 2017 Varun Srinivasan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    struct jsonresult: Decodable{
        let message: String
    }
    var succ = "Success"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(timeToMoveOn), userInfo: nil, repeats: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func timeToMoveOn() {
        let queue = DispatchQueue(label: "me.varuns.partymodeon")
        let defaults = UserDefaults.standard
        let username = defaults.string(forKey: "username")
        let password = defaults.string(forKey: "password")
        if username != nil && password != nil {
            print("defaults available")
            let parameters = ["userid":username , "password":password]
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
                                    self.performSegue(withIdentifier: "LoginViewSegue", sender: self)
                                })
                            } else {
                                print("success")
                                DispatchQueue.main.async(execute: {
                                    self.performSegue(withIdentifier: "welcomeToHomeSegue", sender: self)
                                })
                            }
                        } catch {
                            print(error)
                        }
                    }
                    }.resume()
            }
        }
        else{
            print("defaults not available")
            self.performSegue(withIdentifier: "LoginViewSegue", sender: self)
        }
    }
    
}
