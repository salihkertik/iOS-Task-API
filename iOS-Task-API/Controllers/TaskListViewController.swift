//  ViewController.swift
//  iOS-Task-API
//  Created by Salih Kertik on 20.11.2023.

// To Do;
// Offline Mode

import UIKit
import AVFoundation
import CoreData

class TaskListViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var allTasks: [TaskModel] = []
    var filteredTasks: [TaskModel] = []
    
    var refreshControl = UIRefreshControl()
    
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
        
        if allTasks.isEmpty {
            showAlert(message: "Offline mode. Failed to load data.")
        }
    }
    
    func showAlert(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
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
    
    @objc func refresh(refreshControl: UIRefreshControl){
        DispatchQueue.main.asyncAfter(deadline: .now()+1.5){
            self.fetchData()
            self.refreshControl.endRefreshing()
        }
    }
    
    @objc func handleTap(){
        view.endEditing(true)// close keyboard
    }
    
    func fetchData(){
        NetworkManager.shared.authenticateUser { accessToken in
            guard let accessToken = accessToken else { return }
            
            NetworkManager.shared.fetchTasks(accessToken: accessToken) { tasks in
                guard let tasks = tasks else { return }
                
                self.allTasks = tasks
                self.filteredTasks = tasks
                //+
                DispatchQueue.main.async {
                    self.saveTasksToCoreData()
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
