//
//  EventDetailsViewController.swift
//  partymodeon
//
//  Created by Varun Srinivasan on 12/5/17.
//  Copyright © 2017 Varun Srinivasan. All rights reserved.
//

import UIKit

class EventDetailsViewController: UIViewController {
    struct jsonresult: Decodable{
        let message: String
    }
    let succ: String = "Success"
    @IBOutlet weak var eventName: UITextField!
    @IBOutlet weak var eventMonth: UITextField!
    @IBOutlet weak var eventDay: UITextField!
    @IBOutlet weak var eventYear: UITextField!
    @IBOutlet weak var venue: UITextField!
    @IBOutlet weak var startTime: UITextField!
    @IBOutlet weak var startTimeAMPMSelector: UISegmentedControl!
    @IBOutlet weak var endTime: UITextField!
    @IBOutlet weak var endTimeAMPMSelector: UISegmentedControl!
    @IBOutlet weak var attendees: UITextView!
    @IBOutlet weak var editSwitch: UISwitch!
    @IBOutlet weak var editLabel: UILabel!
    
    var eventname: String!
    var eventdate: String!
    var eventStart: String!
    var eventEnd: String!
    var eventVenue: String!
    
    @IBAction func editSwitchAction(_ sender: Any) {
        if editSwitch.isOn {
            enableFields()
            editLabel.text = "Now Editing"
        } else {
            grayOutFields()
            editLabel.text = "Toggle switch to edit"
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = eventname
        grayOutFields()
        eventName.text = eventname
        let date = getDateFormatted(x: eventdate)
        eventMonth.text = self.getMonth(x: date)
        eventDay.text = self.getDay(x: date)
        eventYear.text = self.getYear(x: date)
        venue.text = eventVenue
        startTime.text = self.getTime(time: eventStart)
        if getAMPM(time: eventStart) == "AM" {
            startTimeAMPMSelector.selectedSegmentIndex = 0
        } else {
            startTimeAMPMSelector.selectedSegmentIndex = 1
        }
        endTime.text = self.getTime(time: eventEnd)
        if getAMPM(time: eventEnd) == "AM" {
            endTimeAMPMSelector.selectedSegmentIndex = 0
        } else {
            endTimeAMPMSelector.selectedSegmentIndex = 1
        }
        
    }
    @IBAction func submitAction(_ sender: Any) {
        let neweventname: String! = self.eventName.text
        let m: String! = self.eventMonth.text
        let d: String! = self.eventDay.text
        let y: String! = self.eventYear.text
        let neweventStart: String! = self.startTime.text
        let neweventEnd: String! = self.endTime.text
        let neweventVenue: String! = self.venue.text
        let startampm: Int! = self.startTimeAMPMSelector.selectedSegmentIndex
        let endampm: Int! = self.endTimeAMPMSelector.selectedSegmentIndex
        
        var parameters = [:] as [String: String]
        let date = getDateFormatted(x: self.eventdate)
        let queue = DispatchQueue(label: "me.varuns.partymodeon")
        queue.async {
            if  neweventname != self.eventname {
                parameters["eventName"] = neweventname
            }
            if neweventVenue != self.eventVenue {
                parameters["venue"] = neweventVenue
            }
            if m != self.getMonth(x: date) || d != self.getDay(x: date) &&  y != self.getYear(x: date) {
                let datestring = m+"/"+d+"/"+y
                let dateFormatterGet = DateFormatter()
                dateFormatterGet.dateFormat = "MM/dd/yyyy"
                
                if dateFormatterGet.date(from: datestring) != nil {
                    parameters["eventDate"] = datestring
                } else {
                    DispatchQueue.main.async(execute: {
                        self.displayAlert(alertTitle: "Error", alertMessage: "Error! Event date field not valid.", action: "Try again")
                    })
                }
            }
            if neweventStart != self.getTime(time: self.eventStart) || self.verifyAMPMchange(x: startampm, y: self.getAMPM(time: self.eventStart)){
                let x: String = startampm == 0 ? neweventStart!+" AM" : neweventStart!+" PM"
                parameters["startTime"] = String(x)
            }
            if neweventEnd != self.getTime(time: self.eventEnd) || self.verifyAMPMchange(x: endampm, y: self.getAMPM(time: self.eventEnd)){
                let x: String = endampm == 0 ? neweventEnd!+" AM" : neweventEnd!+" PM"
                parameters["endTime"] = String(x)
            }
            if parameters.isEmpty != true {
                parameters["oldeventName"] = self.eventname
                parameters["oldeventDate"] = self.eventdate
                guard let url = URL(string: "http://partymodeon.varuns.me/editevent") else { return }
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

    func grayOutFields(){
        eventName.isEnabled = false
        eventMonth.isEnabled = false
        eventDay.isEnabled = false
        eventYear.isEnabled = false
        venue.isEnabled = false
        startTime.isEnabled = false
        startTimeAMPMSelector.isEnabled = false
        endTime.isEnabled = false
        endTimeAMPMSelector.isEnabled = false
        attendees.isEditable = false
    }
    
    func enableFields() {
        eventName.isEnabled = true
        eventMonth.isEnabled = true
        eventDay.isEnabled = true
        eventYear.isEnabled = true
        venue.isEnabled = true
        startTime.isEnabled = true
        startTimeAMPMSelector.isEnabled = true
        endTime.isEnabled = true
        endTimeAMPMSelector.isEnabled = true
        attendees.isEditable = true
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
    func verifyAMPMchange(x: Int, y: String) -> Bool {
        if x == 0 && y == "AM" {
            return false
        } else {
            return true
        }
    }
    func displayAlert(alertTitle: String, alertMessage: String, action: String) {
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        let okAction = UIAlertAction(title: action, style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: false, completion: nil)
    }
}
