//
//  TaskModel.swift
//  iOS-Task-API
//
//  Created by Salih Kertik on 20.11.2023.
//

import Foundation

struct TaskModel:Decodable{
    let task: String
    let title:String
    let description:String
    let colorCode:String
}
