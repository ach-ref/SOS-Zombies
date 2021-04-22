//
//  HospitalsViewController.swift
//  SOS Zombies
//
//  Created by Achref Marzouki on 22/4/21.
//

import UIKit
import MapKit

class HospitalsViewController: UIViewController {

    // MARK: - Sort type
    
    enum SortType {
        case processingTime, distance
        
        var sortButtonTitle: String {
            switch self {
            case .processingTime: return NSLocalizedString("hospitals.waitingTime", comment: "").capitalized
            case .distance: return NSLocalizedString("hospitals.distance", comment: "")
            }
        }
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var tableview: UITableView!
    
    // MARK: - Properties
    
    private let registrationCell = "registrationCell"
    private let hospitalCell = "hospitalCell"
    
    private var hospitals: [Hospital] = []
    private var sortedHospitals: [Hospital] = []
    private var sortType: SortType = .processingTime
    private var userLocationEnabled = false
    
    private weak var sortButton: UIBarButtonItem?
    
    private var locationManager: CLLocationManager!
    private var userLocation: CLLocation? {
        didSet {
            if oldValue == nil, userLocation != nil {
                reloadData()
            }
        }
    }
    
    var registration: Registration!
    var shouldNavigateBack = false
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // initial settings
        fetchData()
        configureView()
    }
    
    // MARK: - Data
    
    private func fetchData() {
        hospitals = Hospital.all(in: CoreDataManager.shared.managedContext)
        sortTypeDidChange()
    }
    
    private func sortTypeDidChange() {
        switch sortType {
        case .processingTime:
            sortedHospitals = hospitals.sorted(by: {
                let timeA = $0.processingTime(forPainLevel: registration.painLevel)
                let timeB = $1.processingTime(forPainLevel: registration.painLevel)
                return timeA < timeB
            })
        case .distance:
            sortedHospitals = hospitals.sorted(by: {
                let distanceA = $0.distanceFrom(userLocation: userLocation)
                let distanceB = $1.distanceFrom(userLocation: userLocation)
                return distanceA < distanceB
            })
        }
    }
    
    // MARK: - UI
    
    private func configureView() {
        // navigation bar
        configureNavigation()
        // table view
        var aNib = UINib(nibName: String(describing: HospitalTableViewCell.self), bundle: nil)
        tableview.register(aNib, forCellReuseIdentifier: hospitalCell)
        aNib = UINib(nibName: String(describing: RegistrationDetailTableViewCell.self), bundle: nil)
        tableview.register(aNib, forCellReuseIdentifier: registrationCell)
        tableview.dataSource = self
        tableview.delegate = self
        // location manager
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
    }
    
    private func configureNavigation() {
        // disable large titles
        navigationController?.navigationBar.prefersLargeTitles = false
        // sort button
        let sortBarButton = UIBarButtonItem(title: sortType.sortButtonTitle,
                                            style: .plain,
                                            target: self,
                                            action: #selector(sortButtonTapped(_:)))
        if shouldNavigateBack {
            navigationItem.rightBarButtonItem = sortBarButton
        } else {
            navigationItem.leftBarButtonItem = sortBarButton
        }
        sortButton = sortBarButton
        // back button
        navigationItem.hidesBackButton = !shouldNavigateBack
        if !shouldNavigateBack {
            let dismissButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissButtonTapped(_:)))
            navigationItem.rightBarButtonItem = dismissButton
        }
    }
    
    private func reloadData() {
        tableview.reloadSections(IndexSet(integer: 1), with: .automatic)
        sortButton?.title = sortType.sortButtonTitle
    }
    
    private func showLocationAlertIfNeeded() {
        // make sure we need to
        guard !UserDefaults.standard.bool(forKey: C.Keys.HIDE_LOCATION_ALERT) else {
            return
        }
        let title = NSLocalizedString("general.warning", comment: "")
        let message = NSLocalizedString("hospitals.userLocationMessage", comment: "")
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.view.tintColor = UIColor(named: "Secondary")
        let hideAction = UIAlertAction(title: NSLocalizedString("general.dontShowAgain", comment: ""), style: .destructive) { _ in
            UserDefaults.standard.setValue(true, forKey: C.Keys.HIDE_LOCATION_ALERT)
            UserDefaults.standard.synchronize()
        }
        alertController.addAction(hideAction)
        let defaultAction = UIAlertAction(title: NSLocalizedString("general.ok", comment: ""), style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Actions
    
    @objc private func dismissButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func sortButtonTapped(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.view.tintColor = UIColor(named: "Secondary")
        alertController.popoverPresentationController?.barButtonItem = sender
        // waiting time sort
        let waitingTimeAction = UIAlertAction(title: NSLocalizedString("hospitals.sortByWaitingTime", comment: ""), style: .default) { [unowned self] _ in
            sortType = .processingTime
            sortTypeDidChange()
            reloadData()
        }
        waitingTimeAction.isEnabled = sortType != .processingTime
        alertController.addAction(waitingTimeAction)
        // distance sort
        let distanceAction = UIAlertAction(title: NSLocalizedString("hospitals.sortByDistance", comment: ""), style: .default) { [unowned self] _ in
            sortType = .distance
            sortTypeDidChange()
            reloadData()
        }
        distanceAction.isEnabled = userLocationEnabled && sortType != .distance
        alertController.addAction(distanceAction)
        // cancel
        let cancelAction = UIAlertAction(title: NSLocalizedString("general.cancel", comment: ""), style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        // present choices
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - Table view data source

extension HospitalsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section == 0 else { return hospitals.count }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // hospitals
        guard indexPath.section == 0 else {
            let cell = tableview.dequeueReusableCell(withIdentifier: hospitalCell, for: indexPath) as! HospitalTableViewCell
            let hospital = sortedHospitals[indexPath.row]
            cell.setupContent(hospital: hospital, painLevel: registration.painLevel, userLocation: userLocation)
            return cell
        }
        
        // registration
        let cell = tableview.dequeueReusableCell(withIdentifier: registrationCell, for: indexPath) as! RegistrationDetailTableViewCell
        cell.setupContent(registration: registration)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard section == 0 else { return NSLocalizedString("hospitals.title", comment: "") }
        return NSLocalizedString("hospitals.registration", comment: "")
    }
}

// MARK: - Table view delegate

extension HospitalsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableview.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as! UITableViewHeaderFooterView
        headerView.textLabel?.textAlignment = .center
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}

// MARK: - Location manager delegate

extension HospitalsViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            userLocationEnabled = true
            locationManager.startUpdatingLocation()
        case .denied:
            showLocationAlertIfNeeded()
            break
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last
    }
}
