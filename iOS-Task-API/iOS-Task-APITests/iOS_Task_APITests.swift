//
//  iOS_Task_APITests.swift
//  iOS-Task-APITests
//
//  Created by Salih Kertik on 21.11.2023.
//

import XCTest
@testable import iOS_Task_API

final class iOS_Task_APITests: XCTestCase {
    
    
    // MARK: - NetworkManager Tests
    
    func testNetworkManagerAuthentication() {
        let expectation = XCTestExpectation(description: "Authentication")
        
        NetworkManager.shared.authenticateUser { accessToken in
            XCTAssertNotNil(accessToken, "Access token should not be nil")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testNetworkManagerFetchTasks() {
        let expectation = XCTestExpectation(description: "Fetch Tasks")
        
        NetworkManager.shared.authenticateUser { accessToken in
            XCTAssertNotNil(accessToken, "Access token should not be nil")
            
            NetworkManager.shared.fetchTasks(accessToken: accessToken!) { tasks in
                XCTAssertNotNil(tasks, "Tasks should not be nil")
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
}
