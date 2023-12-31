//  ViewController.swift
//  iOS-Task-API
//  Created by Salih Kertik on 20.11.2023.


import UIKit
import AVFoundation
import CoreData
import Network

class TaskListViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    var allTasks: [TaskModel] = []
    var filteredTasks: [TaskModel] = []
    
    let monitor = NWPathMonitor()
    var refreshControl = UIRefreshControl()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        tableView.rowHeight = 160
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.darkGray
        tableView.addSubview(refreshControl)
        
        fetchData()
        fetchTasksFromCoreData()
        NetworkControl()
        
        if allTasks.isEmpty {
            showAlert(message: "Offline mode. Failed to load data.")
        }
    }
    
    // MARK: - Offline Mode Control
    func NetworkControl(){
        monitor.pathUpdateHandler = { path in
            if path.status == .unsatisfied {
                // Wi-Fi kapalı
                self.showAlert(message: "You are in Offline Mode.")
            }
        }
        
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }
    
    // MARK: - Core Data Methods
    func saveTasksToCoreData() {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        for task in allTasks {
            let taskEntity = CoreDataModel(context: context)
            taskEntity.task = task.task
            taskEntity.title = task.title
            taskEntity.desc = task.description
            taskEntity.colorCode = task.colorCode
        }
        
        do {
            try context.save()
            print("Data saved to CoreData.")
        } catch {
            print("Error saving data to CoreData: \(error)")
        }
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    func fetchTasksFromCoreData() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do {
            allTasks = try context.fetch(CoreDataModel.fetchRequest()).map {
                TaskModel(task: $0.task ?? "",
                          title: $0.title ?? "",
                          description: $0.desc ?? "",
                          colorCode: $0.colorCode ?? "")
            }
            filteredTasks = allTasks
            tableView.reloadData()
            print("Data fetched from CoreData.")
        } catch {
            print("Error fetching tasks from CoreData: \(error)")
        }
    }
    
    // MARK: - Network Methods
    func fetchData(){
        NetworkManager.shared.authenticateUser { accessToken in
            guard let accessToken = accessToken else { return }
            
            NetworkManager.shared.fetchTasks(accessToken: accessToken) { tasks in
                guard let tasks = tasks else { return }
                
                self.allTasks = tasks
                self.filteredTasks = tasks
                DispatchQueue.main.async {
                    self.saveTasksToCoreData()
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - UI Actions
    @IBAction func scanQRButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "toScannerVC", sender: nil)
    }
    
    // MARK: - AVCaptureMetadataOutputObjectsDelegate
    func found(code: String) {
        print(code)
        // When the QR code is found write it to searchBar
        searchBar.text = code
        filterContentForSearchText(code)
    }
    
    // MARK: - Helper Methods
    @objc func handleTap(){
        // closing the keyboard
        view.endEditing(true)
    }
    
    func showAlert(message: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @objc func refresh(refreshControl: UIRefreshControl){
        DispatchQueue.main.asyncAfter(deadline: .now()+1.5){
            self.fetchData()
            self.refreshControl.endRefreshing()
        }
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
