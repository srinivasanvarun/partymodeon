//
//  NewEventViewController.swift
//  partymodeon
//
//  Created by Varun Srinivasan on 12/5/17.
//  Copyright © 2017 Varun Srinivasan. All rights reserved.
//

import UIKit

class NewEventViewController: UIViewController {

    struct jsonresult: Decodable{
        let message: String
    }
    var succ = "Success"
    
    var users:[String]?
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var organizer: UITextField!
    @IBOutlet weak var eventName: UITextField!
    @IBOutlet weak var eventMonth: UITextField!
    @IBOutlet weak var eventDate: UITextField!
    @IBOutlet weak var eventYear: UITextField!
    @IBOutlet weak var venue: UITextField!
    @IBOutlet weak var startTime: UITextField!
    @IBOutlet weak var startTimeAMPMSelection: UISegmentedControl!
    @IBOutlet weak var endTime: UITextField!
    @IBOutlet weak var endTimeAMPMSelection: UISegmentedControl!
    @IBOutlet weak var attendees: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        organizer.text = defaults.string(forKey: "username")!
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        let x = users?.joined(separator: "; ")
        attendees.text = x
    }
    @IBAction func clearAction(_ sender: Any) {
        eventName.text = ""
        eventMonth.text = ""
        eventDate.text = ""
        eventYear.text = ""
        venue.text = ""
        startTime.text = ""
        endTime.text = ""
        attendees.text = ""
        users = []
    }
    
    @IBAction func SubmitAction(_ sender: Any) {
        let organizer = defaults.string(forKey: "username")!
        let neweventname: String! = self.eventName.text
        let m: String! = self.eventMonth.text
        let d: String! = self.eventDate.text
        let y: String! = self.eventYear.text
        let neweventStart: String! = self.startTime.text
        let neweventEnd: String! = self.endTime.text
        let neweventVenue: String! = self.venue.text
        let startampm: Int! = self.startTimeAMPMSelection.selectedSegmentIndex
        let endampm: Int! = self.endTimeAMPMSelection.selectedSegmentIndex
        var parameters = [:] as [String: Any]
        parameters["userid"] = organizer
        let queue = DispatchQueue(label: "me.varuns.partymodeon")
        queue.async {
            if  neweventname != "" {
                parameters["name"] = neweventname
            } else {
                DispatchQueue.main.async(execute: {
                    self.displayAlert(alertTitle: "Error", alertMessage: "Event name is empty!", action: "OK")
                })
            }
            if neweventVenue != "" {
                parameters["venue"] = neweventVenue
            }
            if m != "" && d != "" &&  y != "" {
                let datestring = m+"/"+d+"/"+y
                let dateFormatterGet = DateFormatter()
                dateFormatterGet.dateFormat = "MM/dd/yyyy"
                
                if dateFormatterGet.date(from: datestring) != nil {
                    parameters["date"] = datestring
                } else {
                    DispatchQueue.main.async(execute: {
                        self.displayAlert(alertTitle: "Error", alertMessage: "Error! Event date field not valid.", action: "Try again")
                    })
                }
            }
            if neweventStart != "" && neweventStart.count == 5 {
                let x = startampm == 0 ? neweventStart+" AM" : neweventStart+" PM"
                parameters["startTime"] = String(x)
            } else {
                DispatchQueue.main.async(execute: {
                    self.displayAlert(alertTitle: "Error", alertMessage: "Error! Start time is not valid. Use HH:MM", action: "Try again")
                })
            }
            if neweventEnd != "" || neweventEnd.count == 5 {
                let x = endampm == 0 ? neweventEnd!+" AM" : neweventEnd!+" PM"
                parameters["endTime"] = String(x)
            } else {
                DispatchQueue.main.async(execute: {
                    self.displayAlert(alertTitle: "Error", alertMessage: "Error! End time is not valid. Use HH:MM", action: "Try again")
                })
            }
            if parameters.isEmpty != true {
                parameters["attendees"] = self.users
                guard let url = URL(string: "http://partymodeon.varuns.me/newevent") else { return }
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
                                    self.displayAlert(alertTitle: "Success", alertMessage: "Changes saved successfully! Click back in the page to go back to the events list.", action: "OK")
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
    func getDateFormatted(x: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        let parsedDate = formatter.date(from: x)
        return formatter.string(from: parsedDate!)
    }
    func getDay(x: String) -> String{
        let startIndex = x.index(x.startIndex, offsetBy: 3)
        let endIndex = x.index(x.startIndex, offsetBy: 4)
        return String(x[startIndex...endIndex])
    }
    func getMonth(x: String) -> String{
        return String(x.prefix(2))
    }
    func getYear(x: String) -> String{
        let startIndex = x.index(x.startIndex, offsetBy: 6)
        return String(x[startIndex...])
        
    }
    func getAMPM(time: String) -> String {
        let startIndex = time.index(time.startIndex, offsetBy: 6)
        return String(time[startIndex...])
    }
    func getTime(time: String) -> String{
        return String(time.prefix(5))
    }
    func displayAlert(alertTitle: String, alertMessage: String, action: String) {
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title: action, style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: false, completion: nil)
    }
}
