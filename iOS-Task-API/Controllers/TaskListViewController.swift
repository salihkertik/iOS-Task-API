//
//  ViewController.swift
//  iOS-Task-API
//
//  Created by Salih Kertik on 20.11.2023.
//

import UIKit

class TaskListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
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
    
}

// TaskListViewController.swift

extension TaskListViewController {
    @objc func refreshData(_ sender: Any) {
        fetchData()
        // Yenileme kontrolünü durdur
        (sender as? UIRefreshControl)?.endRefreshing()
    }
}


extension TaskListViewController {
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

extension TaskListViewController {
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskTableViewCell
        
        let task = filteredTasks[indexPath.row]
        cell.configure(with: task)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Seçilen hücre ile ilgili işlemler buraya eklenebilir
        // Örneğin, detay sayfasına geçiş yapabilirsin
    }
    
    // MARK: - Pull-to-Refresh
    
    func setupRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
}
