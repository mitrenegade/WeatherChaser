//
//  ViewController.swift
//  ChaseWeather
//
//  Created by Bobby Ren on 9/8/23.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

    private let apiService = APIService()

    private let textfield: UITextField = {
        let view = UITextField(frame: .zero)
        view.autocapitalizationType = .none
        view.backgroundColor = .white
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.cgColor
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()

        textfield.becomeFirstResponder()
    }

    private func setupViews() {
        view.backgroundColor = .lightGray

        view.addSubview(textfield)
        textfield.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.height.equalTo(40)
        }
        textfield.delegate = self
    }

    private func performQuery(_ text: String) {
        Task {
            do {
                let result = try await apiService.weather(for: text)
                print("Result \(String(describing: result))")
            } catch let error {
                print("Error \(error)")
            }
        }

    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else {
            return
        }
        performQuery(text)

        textField.text = nil
    }
}
