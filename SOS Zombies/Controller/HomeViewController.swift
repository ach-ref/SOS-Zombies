//
//  HomeViewController.swift
//  SOS Zombies
//
//  Created by Achref Marzouki on 21/4/21.
//

import UIKit
import CoreData
import NVActivityIndicatorView

class HomeViewController: UIViewController {

    // MARK: - IBOutlets
    
    @IBOutlet private weak var loaderView: UIView!
    @IBOutlet private weak var loaderIndicatorView: NVActivityIndicatorView!
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Properties
    
    private let registrationCell = "registrationCell"
    private var selectedRegistration: Registration?
    private var registrations: [Registration] = []
    private let context = CoreDataManager.shared.managedContext
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            // initial setup
            self.registerForNotifications()
            self.configureView()
            DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
                self.fetchData { [unowned self] in
                    DispatchQueue.main.async {
                        self.setupContent()
                    }
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // remove the back button's title
        let backButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButton
    }
    
    // MARK: - deinit
    
    deinit {
        unregisterForNotifications()
    }
    
    // MARK: - Data
    
    private func fetchData(completion: @escaping () -> Void) {
        let backgroundContext = CoreDataManager.shared.persistentContainer.newBackgroundContext()
        AppRepository.shared.refreshRemoteData(in: backgroundContext) { [unowned self] success in
            if !success {
                DispatchQueue.main.async {
                    self.showNetworkError()
                }
            }
            self.registrations = Registration.all(in: CoreDataManager.shared.managedContext)
            completion()
        }
    }
    
    // MARK: - UI
    
    private func configureView() {
        // navigation bar
        title = NSLocalizedString("home.title", comment: "")
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.navigationBar.prefersLargeTitles = true
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped(_:)))
        navigationItem.rightBarButtonItem = addButton
        // table view
        let aNib = UINib(nibName: String(describing: RegistrationTableViewCell.self), bundle: nil)
        tableView.register(aNib, forCellReuseIdentifier: registrationCell)
        tableView.isHidden = true
        tableView.dataSource = self
        tableView.delegate = self
        // home view loader
        loaderIndicatorView.type = .ballClipRotate
        loaderIndicatorView.color = UIColor(named: "Primary")!
        loaderIndicatorView.startAnimating()
    }
    
    private func setupContent() {
        // show navigation bar
        navigationController?.setNavigationBarHidden(false, animated: false)
        // hide loader
        hideLoader()
        // reload data
        tableView.reloadData()
        if registrations.isEmpty {
            let title = NSLocalizedString("general.oops", comment: "")
            let message = NSLocalizedString("home.noRegistrations", comment: "")
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.view.tintColor = UIColor(named: "Secondary")
            let defaultAction = UIAlertAction(title: NSLocalizedString("general.ok", comment: ""), style: .default, handler: nil)
            alertController.addAction(defaultAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    @objc private func refreshData() {
        registrations = Registration.all(in: context)
        tableView.reloadData()
    }
    
    private func hideLoader() {
        loaderIndicatorView.stopAnimating()
        loaderView.isHidden = true
        tableView.isHidden = false
    }
    
    private func showNetworkError() {
        let title = NSLocalizedString("general.oops", comment: "")
        let message = NSLocalizedString("home.networkError", comment: "")
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.view.tintColor = UIColor(named: "Secondary")
        let defaultAction = UIAlertAction(title: NSLocalizedString("general.ok", comment: ""), style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Actions
    
    @objc private func addButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "Register", sender: self)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Hospitals" {
            guard let registration = selectedRegistration else { fatalError("Can't find any selected registration!") }
            let controller = segue.destination as! HospitalsViewController
            controller.registration = registration
            controller.shouldNavigateBack = true
            selectedRegistration = nil
        }
    }
    
    // MARK: - Notifications
    
    private func registerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData), name: .userDidUpdateRegistration, object: nil)
    }
    
    private func unregisterForNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Table view data source

extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return registrations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: registrationCell, for: indexPath) as! RegistrationTableViewCell
        let registration = registrations[indexPath.row]
        cell.setupContent(registration: registration)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let registration = registrations[indexPath.row]
            context.delete(registration)
            context.saveContext()
            registrations.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

// MARK: - Table view delegate

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRegistration = registrations[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "Hospitals", sender: self)
    }
}
