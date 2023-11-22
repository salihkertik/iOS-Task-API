//
//  NetworkManager.swift
//  iOS-Task-API
//
//  Created by Salih Kertik on 20.11.2023.
//

import Foundation

class NetworkManager {
    
    static let shared = NetworkManager()
    
    private init() {}
    
    // MARK: - authenticateUser
    func authenticateUser(completion: @escaping (String?) -> Void) {
        let headers = [
            "Authorization": "Basic QVBJX0V4cGxvcmVyOjEyMzQ1NmlzQUxhbWVQYXNz",
            "Content-Type": "application/json"
        ]
        let parameters = [
            "username": "365",
            "password": "1"
        ]
        
        guard let url = URL(string: "https://api.baubuddy.de/index.php/login") else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            completion(nil)
            return
        }
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let oauth = json["oauth"] as? [String: Any],
               let accessToken = oauth["access_token"] as? String {
                completion(accessToken)
            } else {
                completion(nil)
            }
        }
        
        task.resume()
    }
    
    // MARK: - fetchTasks
    func fetchTasks(accessToken: String, completion: @escaping ([TaskModel]?) -> Void) {
        let urlString = "https://api.baubuddy.de/dev/index.php/v1/tasks/select"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error fetching tasks: \(error)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let tasks = try decoder.decode([TaskModel].self, from: data)
                completion(tasks)
            } catch {
                print("Error decoding tasks: \(error)")
                completion(nil)
            }
        }
        
        task.resume()
    }
}


