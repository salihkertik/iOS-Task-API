//  ViewController.swift
//  iOS-Task-API
//  Created by Salih Kertik on 20.11.2023.

// To Do;

// Extension and Function classification
// Refresh
// Offline Mode
// Button Icon

import UIKit
import AVFoundation

class TaskListViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var allTasks: [TaskModel] = []
    var filteredTasks: [TaskModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        fetchData()
        
        tableView.rowHeight = 160
    }
    
    
    func fetchData(){
        NetworkManager.shared.authenticateUser { accessToken in
            guard let accessToken = accessToken else { return }
            
            NetworkManager.shared.fetchTasks(accessToken: accessToken) { tasks in
                guard let tasks = tasks else { return }
                
                self.allTasks = tasks
                self.filteredTasks = tasks
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    
    @IBAction func scanQRButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "toScannerVC", sender: nil)
    }
    
    // QR Kodu bulduğunda searchBar'a yaz.
    func found(code: String) {
        print(code)
        
        // QR kodu bulunduğunda searchBar'a yaz
        searchBar.text = code
        filterContentForSearchText(code)
    }
}


// MARK: - UISearchBarDelegate
extension TaskListViewController: UISearchBarDelegate {
    func filterContentForSearchText(_ searchText: String) {
        filteredTasks = allTasks.filter { task in
            return task.title.lowercased().contains(searchText.lowercased()) ||
            task.description.lowercased().contains(searchText.lowercased()) ||
            task.task.lowercased().contains(searchText.lowercased()) ||
            task.colorCode.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentForSearchText(searchText)
        if let searchText = searchBar.text, searchText.isEmpty {
            filteredTasks = allTasks
            tableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        filterContentForSearchText("")
    }
    
}

// MARK: - UITableViewDataSource,UITableViewDelegate
extension TaskListViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskTableViewCell
        
        let task = filteredTasks[indexPath.row]
        cell.configure(with: task)
        
        return cell
    }
}
