//
//  HomeViewController.swift
//  partymodeon
//
//  Created by Varun Srinivasan on 11/13/17.
//  Copyright © 2017 Varun Srinivasan. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
//    struct jsonresult: Decodable{
//        let _id: String
//        let eventname: String
//        let eventdate: String
//    }
    
    var count = 0
    let defaults = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()
        let username = defaults.string(forKey: "username")!
        print(username)
        //count = showSelfEvents(username: username, count: count)
    }
    
    func showSelfEvents(username: String, count: Int) -> Int{
        let urlString = "http://partymodeon.varuns.me/upcomingselfevents?id="+username
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        _ = URLSession.shared.dataTask(with: request) {(data, response, error) in
            if let data = data {
                do {
                    let jsonres = try JSONSerialization.jsonObject(with: data, options: [])
                    if let jsonarray = jsonres as? [[String: Any]]{
                        for json in jsonarray{
                            print(json["eventDate"] as Any)
                            self.createButton(id: json["_id"] as! String, x: json["eventName"] as! String, y: json["eventDate"] as! String)
                        }
                    }
                } catch {
                    print(error)
                }
            }
        }.resume()
        return count
    }
    func showAcceptedEvents(count: Int) -> Int{
        return count
    }
    func showUnAcceptedEvents(count: Int) -> Int{
        return count
    }
    func createButton(id: String, x: String, y: String) {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: 100.0, y: 100.0, width: 200.0, height: 100.0)
        button.setTitle(NSLocalizedString(x, comment: y), for: .normal)
        button.backgroundColor = .gray
        button.addTarget(self, action: #selector(buttonAction(sender:)), for: .touchUpInside)
        view.addSubview(button)
    }
    @objc func buttonAction(sender: UIButton) {
        print(sender.tag)
    }
}
