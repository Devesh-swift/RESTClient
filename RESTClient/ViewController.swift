//
//  ViewController.swift
//  RESTClient
//
//  Created by Alexander Gaidukov on 11/18/16.
//  Copyright © 2016 Alexander Gaidukov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    static let sharedWebClient = JRCWebClient.init(baseUrl: "http://www.mocky.io/v2")
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var friends: [User] = [] {
        didSet {
            updateUI()
        }
    }
    
    var friendsTask: URLSessionDataTask!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: .zero)
        loadFriends()
    }
    
    private func showErrorAlert(with message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func moveToLogin() {
        
    }
    
    private func handleError(_ error: JRCWebError<CustomError>) {
        switch error {
        case .noInternetConnection:
            showErrorAlert(with: "The internet connection is lost")
        case .unauthorized:
            moveToLogin()
        case .other:
            showErrorAlert(with: "Unfortunately something went wrong")
        case .custom(let error):
            showErrorAlert(with: error.message)
        }
    }
    
    @IBAction private func loadFriends() {
        friendsTask?.cancel() //Cancel previous loading task.
        
        activityIndicator.startAnimating() //Show loading indicator
        
        friendsTask = ViewController.sharedWebClient.load(path: "/59e8956d0f00000708aefb59") {[weak self](response: FriendsResponse?, error: JRCWebError<CustomError>?) in
            
            guard let controller = self else { return }
            
            DispatchQueue.main.async {
                
                controller.activityIndicator.stopAnimating()
                
                if let friends = response?.friends {
                    controller.friends = friends
                } else if let error = error {
                    controller.handleError(error)
                }
            }
        }
    }
    
    private func updateUI() {
        tableView.reloadData()
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath)
        let friend = friends[indexPath.row]
        cell.textLabel?.text = friend.name
        cell.detailTextLabel?.text = friend.email
        return cell
    }
}

