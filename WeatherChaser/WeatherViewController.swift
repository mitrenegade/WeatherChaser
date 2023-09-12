//
//  ViewController.swift
//  WeatherChaser
//
//  Created by Bobby Ren on 9/8/23.
//

import UIKit
import SnapKit
import CoreLocation

class WeatherViewController: UIViewController {

    private let viewModel: WeatherViewModel

    private let textfield: UITextField = {
        let view = UITextField(frame: .zero)
        view.autocapitalizationType = .none
        view.backgroundColor = .white
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.cgColor
        return view
    }()

    private let button: UIButton = {
        let button = UIButton(frame: .zero)
        button.setImage(UIImage(systemName: "location.circle.fill"), for: .normal)
        return button
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

    init(viewModel: WeatherViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        viewModel.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: -

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()

        button.addAction(UIAction(handler: { [weak self] _ in
            self?.didTapButton()
        }), for: .touchUpInside)

        if let oldText = getCachedQuery() {
            textfield.text = oldText
            performQuery(oldText)
        } else {
            textfield.becomeFirstResponder()
        }
    }

    private func setupViews() {
        view.backgroundColor = .lightGray

        view.addSubview(textfield)
        textfield.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.right.equalToSuperview().offset(-80)
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.height.equalTo(40)
        }
        textfield.delegate = self

        view.addSubview(button)
        button.snp.makeConstraints {
            $0.centerY.equalTo(textfield)
            $0.leading.equalTo(textfield.snp.trailing).offset(8)
            $0.width.height.equalTo(40)
        }

        view.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.centerX.equalTo(textfield)
            $0.top.equalTo(textfield.snp.bottom).offset(20)
            $0.width.height.equalTo(100)
        }

        view.addSubview(label)
        label.snp.makeConstraints {
            $0.leading.equalTo(textfield)
            $0.trailing.equalTo(button)
            $0.top.equalTo(imageView.snp.bottom).offset(20)
        }

        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints {
            $0.centerX.centerY.equalTo(view)
        }
        activityIndicator.stopAnimating()
    }

    /// Query the API for weather given a string
    /// - Parameters:
    ///     - text: the search string entered by the user to fetch location
    func performQuery(_ text: String) {
        cacheQuery(text)
        activityIndicator.startAnimating()
        label.text = nil
        imageView.image = nil
        Task {
            do {
                let result = try await viewModel.fetchWeather(for: text)
                guard let weatherDetail = result.weather.first else {
                    activityIndicator.stopAnimating()
                    return
                }

                let image = try await viewModel.fetchWeatherIcon(for: weatherDetail)
                imageView.image = image
                label.text = result.description

                activityIndicator.stopAnimating()
            } catch {
                showError("Weather could not be loaded for \(text)")
                activityIndicator.stopAnimating()
            }
        }
    }

    private func didTapButton() {
        viewModel.fetchCurrentLocation()
    }

    private func showError(_ message: String) {
        /// TODO: log this error for analytics
        textfield.text = nil
        imageView.image = nil
        label.text = message
    }
}

extension WeatherViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else {
            return
        }
        performQuery(text)
    }
}

// MARK: - Caching last entry
extension WeatherViewController {
    private enum DefaultsKeys {
        static let lastQuery = "lastQuery"
    }

    func cacheQuery(_ string: String) {
        UserDefaults.standard.set(string, forKey: DefaultsKeys.lastQuery)
    }

    func getCachedQuery() -> String? {
        UserDefaults.standard.string(forKey: DefaultsKeys.lastQuery)
    }
}

// MARK: - WeatherViewModelDelegate
extension WeatherViewController: WeatherViewModelDelegate {
    func didReceiveLocationError(_ error: Error) {
        DispatchQueue.main.async {
            self.showError("Could not fetch your current location. Error: \(error)")
        }
    }

    func didDenyLocationPermission() {
        DispatchQueue.main.async {
            self.showError("You have disabled permissions for location. Please enabled it in your settings app.")
        }
    }

    func didFinishReverseGeocode(_ city: String) {
        // geocoding happens on a background thread
        DispatchQueue.main.async {
            self.textfield.text = city
            self.performQuery(city)
        }
    }
}
