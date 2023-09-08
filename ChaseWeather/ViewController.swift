//
//  ViewController.swift
//  ChaseWeather
//
//  Created by Bobby Ren on 9/8/23.
//

import UIKit

class ViewController: UIViewController {

    private let apiService = APIService()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        // test APIService
        Task {
            do {
                let result = try await apiService.weather(for: "san jose")
                print("Result \(String(describing: result))")
            } catch let error {
                print("Error \(error)")
            }
        }
    }
}

