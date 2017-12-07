//
//  UnacceptedEventsViewController.swift
//  partymodeon
//
//  Created by Varun Srinivasan on 12/5/17.
//  Copyright © 2017 Varun Srinivasan. All rights reserved.
//

import UIKit

class UnacceptedEventsViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    var unaccevents : [Events] = []
    @IBOutlet weak var UnacceptedEventsTable: UITableView!
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UnacceptedEventsTable.delegate = self
        UnacceptedEventsTable.dataSource = self
        self.UnacceptedEventsTable.rowHeight = 70;
        fetchUnacceptedEvents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUnacceptedEvents()
    }
    
    func fetchUnacceptedEvents(){
        let username = defaults.string(forKey: "username")!
        let urlString = "http://partymodeon.varuns.me/upcomingunacceptedevents?id="+username
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        _ = URLSession.shared.dataTask(with: request) {(data, response, error) in
            if error != nil {
                print(error!)
            }
            if let data = data {
                self.unaccevents = [Events]()
                do {
                    let jsonres = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    if let jsonarray = jsonres as? [[String: Any]]{
                        for j in jsonarray {
                            if let name = j["eventName"] as? String, let date = j["eventDate"] as? String {
                                let d = self.getDateFormatted(x: date)
                                if self.compareDate(date: d){
                                    let event = Events()
                                    event.eventName = name
                                    event.eventDate = d
                                    self.unaccevents.append(event)
                                }
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self.UnacceptedEventsTable.reloadData()
                    }
                } catch {
                    print(error)
                }
            }
            }.resume()
    }
    
    func getDateFormatted(x: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        let parsedDate = formatter.date(from: x)
        return formatter.string(from: parsedDate!)
        
    }
    
    func compareDate(date: String) -> Bool {
        let current = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        let parsedDate : Date = formatter.date(from: date)!
        if current <= parsedDate{
            return true
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.unaccevents.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.unaccevents.count > 0 {
            self.UnacceptedEventsTable.backgroundView = nil
            self.UnacceptedEventsTable.separatorStyle = .singleLine
            return 1
        }
        
        let rect = CGRect(x: 0,
                          y: 0,
                          width: self.UnacceptedEventsTable.bounds.size.width,
                          height: self.UnacceptedEventsTable.bounds.size.height)
        let noDataLabel: UILabel = UILabel(frame: rect)
        
        noDataLabel.text = "Sweet!! \r\nYou have accepted all events, \r\n so get ready to wear \r\nyour party mask!!! \r\n\n\u{1F3AD}"
        noDataLabel.textAlignment = NSTextAlignment.center
        noDataLabel.numberOfLines = 6
        self.UnacceptedEventsTable.backgroundView = noDataLabel
        self.UnacceptedEventsTable.separatorStyle = .none
        
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UnacceptedEventsTable.dequeueReusableCell(withIdentifier: "UnacceptedEvent", for: indexPath) as! UnacceptedEventsCell
        cell.title.font = UIFont.boldSystemFont(ofSize: cell.title.font.pointSize)
        cell.title.text = self.unaccevents[indexPath.item].eventName
        cell.date.text = self.unaccevents[indexPath.item].eventDate
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "UnacceptedToAcceptViewSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? AcceptEventViewController{
            destination.eventName = unaccevents[(UnacceptedEventsTable.indexPathForSelectedRow?.row)!].eventName
            destination.attendee = defaults.string(forKey: "username")!
            destination.eventDate = unaccevents[(UnacceptedEventsTable.indexPathForSelectedRow?.row)!].eventDate
        }
    }
}
