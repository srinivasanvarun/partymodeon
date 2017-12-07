//
//  AcceptedEventsViewController.swift
//  partymodeon
//
//  Created by Varun Srinivasan on 12/5/17.
//  Copyright © 2017 Varun Srinivasan. All rights reserved.
//

import UIKit

class AcceptedEventsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var accevents : [Events] = []
    @IBOutlet weak var acceptedEventsTable: UITableView!
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        acceptedEventsTable.delegate = self
        acceptedEventsTable.dataSource = self
        self.acceptedEventsTable.rowHeight = 70;
        fetchAcceptedEvents()
        
    }
    func fetchAcceptedEvents(){
        let username = defaults.string(forKey: "username")!
        let urlString = "http://partymodeon.varuns.me/upcomingacceptedevents?id="+username
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        _ = URLSession.shared.dataTask(with: request) {(data, response, error) in
            if error != nil {
                print(error!)
            }
            if let data = data {
                self.accevents = [Events]()
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
                                    self.accevents.append(event)
                                }
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self.acceptedEventsTable.reloadData()
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
        return self.accevents.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.accevents.count > 0 {
            self.acceptedEventsTable.backgroundView = nil
            self.acceptedEventsTable.separatorStyle = .singleLine
            return 1
        }
        
        let rect = CGRect(x: 0,
                          y: 0,
                          width: self.acceptedEventsTable.bounds.size.width,
                          height: self.acceptedEventsTable.bounds.size.height)
        let noDataLabel: UILabel = UILabel(frame: rect)
        
        noDataLabel.text = "No events to show.. \r\nWait for people to invite you, \r\n or create your own event and \r\nget the party started!!! \r\n\n\u{1F38A}"
        noDataLabel.textAlignment = NSTextAlignment.center
        noDataLabel.numberOfLines = 6
        self.acceptedEventsTable.backgroundView = noDataLabel
        self.acceptedEventsTable.separatorStyle = .none
        
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = acceptedEventsTable.dequeueReusableCell(withIdentifier: "AcceptedEvent", for: indexPath) as! AcceptedEventsCell
        cell.title.font = UIFont.boldSystemFont(ofSize: cell.title.font.pointSize)
        cell.title.text = self.accevents[indexPath.item].eventName
        cell.date.text = self.accevents[indexPath.item].eventDate
        return cell
    }
    
}
