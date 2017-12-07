//
//  UsersTableViewController.swift
//  partymodeon
//
//  Created by Varun Srinivasan on 12/6/17.
//  Copyright © 2017 Varun Srinivasan. All rights reserved.
//

import UIKit

class UsersTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var users: [Users] = []
    var selectedUsers: [String] = []
    @IBOutlet weak var UsersTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        UsersTable.delegate = self
        UsersTable.dataSource = self
        self.UsersTable.rowHeight = 70;
        fetchUsers()
    }
    func fetchUsers(){
        let urlString = "http://partymodeon.varuns.me/users"
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        _ = URLSession.shared.dataTask(with: request) {(data, response, error) in
            if error != nil {
                print(error!)
            }
            if let data = data {
                self.users = [Users]()
                do {
                    let jsonres = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    if let jsonarray = jsonres as? [[String: Any]]{
                        for j in jsonarray {
                            if let id = j["_id"] as? String, let fname = j["firstName"] as? String, let lname = j["lastName"] as? String {
                                    let user = Users()
                                    user.id = id
                                    user.firstname = fname
                                    user.lastname = lname
                                    self.users.append(user)
                                }
                            }
                        }
                    DispatchQueue.main.async {
                        self.UsersTable.reloadData()
                    }
                } catch {
                    print(error)
                }
            }
            }.resume()
    }
    
    @IBAction func doneAction(_ sender: Any) {
        performSegue(withIdentifier: "UsersTableToAddEventSegue", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? NewEventViewController{
            destination.users = selectedUsers
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UsersTable.dequeueReusableCell(withIdentifier: "Usercell", for: indexPath) as! UsersCell
        cell.UserName.font = UIFont.boldSystemFont(ofSize: cell.UserName.font.pointSize)
        cell.UserName.text = self.users[indexPath.item].lastname!+", "+self.users[indexPath.item].firstname!
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedUsers.append(users[(UsersTable.indexPathForSelectedRow?.row)!].id!)
    }
}
