//
//  TaskTableViewCell.swift
//  iOS-Task-API
//
//  Created by Salih Kertik on 20.11.2023.
//

import UIKit

class TaskTableViewCell: UITableViewCell {
    
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    func configure(with task: TaskModel){
        taskLabel.text = task.task
        titleLabel.text = task.title
        descriptionLabel.text = task.description
        
        if let color = hexStringToUIColor(hex: task.colorCode) {
               backgroundColor = color
           } else {
               // Default bir renk kullanabilirsiniz
               backgroundColor = UIColor.gray
           }
    }
    
    func hexStringToUIColor(hex: String) -> UIColor? {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0

        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }

}
