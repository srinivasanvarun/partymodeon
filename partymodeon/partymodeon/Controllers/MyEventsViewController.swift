//
//  MyEventsViewController.swift
//  partymodeon
//
//  Created by Varun Srinivasan on 11/17/17.
//  Copyright © 2017 Varun Srinivasan. All rights reserved.
//

import UIKit

class MyEventsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var events : [Events] = []
    @IBOutlet weak var myEventsTable: UITableView!
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myEventsTable.delegate = self
        myEventsTable.dataSource = self
        self.myEventsTable.rowHeight = 70;
        fetchEvents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchEvents()
    }
    
    func fetchEvents(){
        let username = defaults.string(forKey: "username")!
        let urlString = "http://partymodeon.varuns.me/upcomingselfevents?id="+username
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        _ = URLSession.shared.dataTask(with: request) {(data, response, error) in
            if error != nil {
                print(error!)
            }
            if let data = data {
                self.events = [Events]()
                do {
                    let jsonres = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    if let jsonarray = jsonres as? [[String: Any]]{
                        for j in jsonarray {
                            if let name = j["eventName"] as? String, let date = j["eventDate"] as? String, let start = j["startTime"] as? String, let end = j["endTime"] as? String, let venue = j["venue"] as? String {
                                let d = self.getDateFormatted(x: date)
                                if self.compareDate(date: d){
                                    print(name,date)
                                    let event = Events()
                                    event.eventName = name
                                    event.eventDate = d
                                    event.eventStart = start
                                    event.eventEnd = end
                                    event.eventVenue = venue
//                                    event.attendees = attendees
                                    self.events.append(event)
                                }
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self.myEventsTable.reloadData()
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
        return self.events.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.events.count > 0 {
            self.myEventsTable.backgroundView = nil
            self.myEventsTable.separatorStyle = .singleLine
            return 1
        }
        
        let rect = CGRect(x: 0,
                          y: 0,
                          width: self.myEventsTable.bounds.size.width,
                          height: self.myEventsTable.bounds.size.height)
        let noDataLabel: UILabel = UILabel(frame: rect)
        
        noDataLabel.text = "No events created. \r\nClick 'Add new event' button below \r\nand get the pee-pees flying!!! \r\n\n\u{1F389}"
        noDataLabel.textAlignment = NSTextAlignment.center
        noDataLabel.numberOfLines = 5
        self.myEventsTable.backgroundView = noDataLabel
        self.myEventsTable.separatorStyle = .none
        
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = myEventsTable.dequeueReusableCell(withIdentifier: "MyEvent", for: indexPath) as! MyEventsCell
        cell.title.font = UIFont.boldSystemFont(ofSize: cell.title.font.pointSize)
        cell.title.text = self.events[indexPath.item].eventName
        cell.date.text = self.events[indexPath.item].eventDate
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "myEventsToEventDetailSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? EventDetailsViewController{
            destination.eventname = events[(myEventsTable.indexPathForSelectedRow?.row)!].eventName
            destination.eventdate = events[(myEventsTable.indexPathForSelectedRow?.row)!].eventDate
            destination.eventStart = events[(myEventsTable.indexPathForSelectedRow?.row)!].eventStart
            destination.eventEnd = events[(myEventsTable.indexPathForSelectedRow?.row)!].eventEnd
            destination.eventVenue = events[(myEventsTable.indexPathForSelectedRow?.row)!].eventVenue
//            destination.attendeeslist = events[(myEventsTable.indexPathForSelectedRow?.row)!].attendees
        }
    }
}
