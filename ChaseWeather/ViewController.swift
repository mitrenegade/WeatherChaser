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

    private let label: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 0
        return label
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

        view.addSubview(label)
        label.snp.makeConstraints {
            $0.left.right.equalTo(textfield)
            $0.top.equalTo(textfield).offset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
        }
    }

    private func performQuery(_ text: String) {
        Task {
            do {
                let result = try await apiService.weather(for: text)
            } catch let error {
                print("Query Error \(error)")
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
