//
//  ViewController.swift
//  ChaseWeather
//
//  Created by Bobby Ren on 9/8/23.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

    private let apiService: APIService
    private let imageService: ImageService

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

    private let imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.hidesWhenStopped = true
        return view
    }()

    // MARK:

    init(apiService: APIService = APIService(),
         imageService: ImageService = ImageService()) {
        self.apiService = apiService
        self.imageService = imageService

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()

        if let query = getCachedQuery() {
            textfield.text = query
            performQuery(query)
        } else {
            textfield.becomeFirstResponder()
        }
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

        view.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.centerX.equalTo(textfield)
            $0.top.equalTo(textfield).offset(20)
            $0.width.height.equalTo(100)
        }

        view.addSubview(label)
        label.snp.makeConstraints {
            $0.left.right.equalTo(textfield)
            $0.top.equalTo(imageView).offset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
        }

        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints {
            $0.centerX.centerY.equalTo(view)
        }
        activityIndicator.stopAnimating()
    }

    private func performQuery(_ text: String) {
        activityIndicator.startAnimating()
        label.text = nil
        imageView.image = nil
        Task {
            do {
                let result = try await apiService.weather(for: text)
                guard let weatherDetail = result.weather.first else {
                    activityIndicator.stopAnimating()
                    return
                }

                let image = try await imageService.icon(for: weatherDetail)
                imageView.image = image
                label.text = result.description

                activityIndicator.stopAnimating()
            } catch let error {
                label.text = "Query Error: \(error)"
                activityIndicator.stopAnimating()
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
        cacheQuery(text)
    }
}

// MARK: - Caching last entry
extension ViewController {
    private enum DefaultsKeys {
        static let lastQuery = "lastQuery"
    }

    func cacheQuery(_ string: String) {
        UserDefaults.standard.set(string, forKey: DefaultsKeys.lastQuery)
        UserDefaults.standard.synchronize()
    }

    func getCachedQuery() -> String? {
        UserDefaults.standard.string(forKey: DefaultsKeys.lastQuery)
    }
}
