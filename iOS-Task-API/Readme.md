#  iOS TASK API 

#### This project is an iOS application developed using the Swift programming language. The application has a simple and user-friendly interface that fetches specific tasks from an API, allowing users to view these tasks.

https://github.com/salihkertik/iOS-Task-API/assets/96303345/b872a0c5-f27e-4f1c-a986-16d1959ab46b

## Project Structure
### The project includes the following essential components:
####  TaskModel.swift:  A Decodable structure representing task data.
####  NetworkManager.swift: A network manager class that communicates with the API and handles the process of fetching tasks.
####  TaskTableViewCell.swift: A custom cell class used to display task data in a table view.
####  ViewController.swift: The main application screen, managing the display of tasks and functioning as a view controller.
####  ScannerViewController.swift: A screen that scans QR codes and processes the found codes.
####  iOS_Task_APITests.swift: XCTest test classes testing the basic functionality of the network manager.

## Used Libraries
### The project utilizes the following significant libraries:

####  AVFoundation: A library providing functionality for audio and video processing. It was used for QR transactions.
####  CoreData: A framework used for database management.
####  Network: The NWPathMonitor class for connection status control.

## How to Use?

#### The project has a straightforward and user-friendly interface. Tasks are listed on the main screen, and users can filter specific tasks using the search bar. Additionally, users can navigate to the QR code scanner screen by pressing the "Scan QR" button, allowing them to quickly find a task using a QR code.

## Tests
#### The project uses XCTest to test the fundamental functionality of the network manager.

# Developer
The project was developed by Salih Kertik. For contact: salihkertik1453@gmail.com



