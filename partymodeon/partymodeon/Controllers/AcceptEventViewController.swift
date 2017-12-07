//
//  AcceptEventViewController.swift
//  partymodeon
//
//  Created by Varun Srinivasan on 12/6/17.
//  Copyright © 2017 Varun Srinivasan. All rights reserved.
//

import UIKit

class AcceptEventViewController: UIViewController {
    
    struct jsonresult: Decodable{
        let message: String
    }
    let succ: String = "Success"
    
    var eventName: String!
    var eventDate: String!
    var attendee: String!
    
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var numOfGuestsTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        headingLabel.text = eventName

    }
    @IBAction func acceptAction(_ sender: Any) {
        let num: String = numOfGuestsTextfield.text!
        var parameters = [:] as [String: Any]
        let queue = DispatchQueue(label: "me.varuns.partymodeon")
        queue.async {
            parameters["userid"] = self.attendee
            if num == "" {
                parameters["numOfGuests"] = String(1)
            } else {
                parameters["numOfGuests"] = num
            }
            parameters["name"] = self.eventName
            parameters["date"] = self.eventDate
            guard let url = URL(string: "http://partymodeon.varuns.me/eventaccept") else { return }
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
                                self.displayAlert(alertTitle: "Success", alertMessage: "Event accepted!", action: "OK")
                            })
                        }
                    } catch {
                        print(error)
                    }
                }
            }.resume()
        }
    }
    @IBAction func rejectAction(_ sender: Any) {
    }
    func displayAlert(alertTitle: String, alertMessage: String, action: String) {
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title: action, style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: false, completion: nil)
    }
}
