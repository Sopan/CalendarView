//
//  WeatherViewController.swift
//  ProgrammingChallenge
//
//  Created by Sopan Sharma on 2/19/17.
//  Copyright © 2017 Sopan Sharma. All rights reserved.
//

import UIKit

class WeatherViewController: UIViewController {
    
    fileprivate struct Constants {
        static let weatherViewTitle = "Weather"
        static let dateFormat = "EEEE"
        static let wundergroundAPIKey = "ADD_YOUR_KEY"
        static let weatherViewTableCellIdentifier = "weatherViewTableCellReuseIdentifier"
        static let loadingText = "Loading..."
    }
    
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var weatherConditionLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    private var task: URLSessionDataTask?
    private var locationTracker: LocationTracker?
    fileprivate var forecast: Forecast?
    
    lazy fileprivate var loadingIndicator: UIActivityIndicatorView = {
        let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        return loadingIndicator
    }()
    
    static fileprivate let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.dateFormat
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Constants.weatherViewTitle
        view.addSubview(loadingIndicator)
        loadingIndicator.center = view.center
        loadingIndicator.startAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fetchCurrentLocation()
    }
    
    func fetch(latitude: Double, longitude: Double) {
        // Get forecastURL
        guard let url = WundergroundForecastURL(apiKey: Constants.wundergroundAPIKey, latitude: latitude, longitude: longitude),
            task?.originalRequest?.url != url || task?.state != .running else { return }
        
        let request = URLSessionDataTaskResponse(serializeJSON: true) { (json: Any) -> Forecast? in
            guard let json = json as? [String: Any] else { return nil }
            return Forecast.fromJSON(json: json)
        }
        
        task?.cancel()
        task = URLSession.shared.fetch(url: url, request: request) { [weak self] (result: URLSessionResult) in
            guard let `self` = self else { return }
            self.loadingIndicator.stopAnimating()
            switch result {
            case let .success(forecast):
                self.forecast = forecast
                self.updateTitle()
            case let .failure(error):
                let failureAlertController = UIAlertController(title: "Error", message: "Oops! Please try again later", preferredStyle: .alert)
                let okButtonAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
                    print("WeatherViewController: Error fetching forecast \(error)")
                    self.navigationController?.dismiss(animated: true, completion: nil)
                }
                failureAlertController.addAction(okButtonAction)
                self.present(failureAlertController, animated: true, completion:nil)
            }
        }
    }
    
    @IBAction func dismissViewController(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Private APIs
    
    private func fetchCurrentLocation() {
        locationTracker = LocationTracker()
        locationTracker?.delegate = self
        locationTracker?.getLocation()
    }
    
    private func updateTitle() {
        cityNameLabel.text = forecast?.location?.city
        weatherConditionLabel.text = forecast?.daily?[0].description
        if let dailyForecast = forecast?.daily,
            let highTemperature = forecast?.daily?[0].high,
            let lowTemperature = forecast?.daily?[0].low,
            dailyForecast.count > 0 {
            temperatureLabel.attributedText = highLowAttributedString(high: highTemperature, low: lowTemperature, size: 85)
        }
        tableView.reloadData()
    }
    
}

extension WeatherViewController: LocationTrackerDelegate {
    
    func didFinish(_ tracker: LocationTracker, result: LocationResult) {
        switch result {
        case let .success(location):
            fetch(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        case let .failure(error):
            print("WeatherViewController: Error tracking location \(error)")
        }
    }
    
}

extension WeatherViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let dailyForecast = forecast?.daily else { return 1 }
        
        return dailyForecast.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.weatherViewTableCellIdentifier)
        
        var text = Constants.loadingText
        var detailAttributedText = NSAttributedString()
        if let dailyForecast = forecast?.daily,
            let highTemperature = forecast?.daily?[indexPath.row].high,
            let lowTemperature = forecast?.daily?[indexPath.row].low,
            dailyForecast.count > 0 {
            text = WeatherViewController.dateFormatter.string(from: dailyForecast[indexPath.row].date)
            detailAttributedText = highLowAttributedString(high: highTemperature, low: lowTemperature)
        }
        
        cell?.textLabel?.text = text
        cell?.detailTextLabel?.attributedText = detailAttributedText
        return cell!
    }
    
}
