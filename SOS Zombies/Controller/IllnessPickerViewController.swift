//
//  IllnessPickerViewController.swift
//  SOS Zombies
//
//  Created by Achref Marzouki on 22/4/21.
//

import UIKit
import CoreData
import NVActivityIndicatorView

class IllnessPickerViewController: UIViewController {

    // MARK: - IBOutlets
    
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Properties
    
    private let illnessCell = "illnessCell"
    private var selectedIllness: Illness?
    private var illnesses: [Illness] = []
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // initial setup
        fetchData()
        configureView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // remove the back button's title
        let backButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButton
    }
    
    // MARK: - Data
    
    private func fetchData() {
        illnesses = Illness.all(in: CoreDataManager.shared.managedContext)
    }
    
    // MARK: - UI
    
    private func configureView() {
        // navigation bar
        title = NSLocalizedString("illnessPicker.title", comment: "")
        let dismissButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissButtonTapped(_:)))
        navigationItem.rightBarButtonItem = dismissButton
        // table view
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // MARK: - Actions
    
    @objc private func dismissButtonTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Register" {
            guard let illness = selectedIllness else { fatalError("Can't find any selected illness!") }
            let controller = segue.destination as! RegisterViewController
            controller.illness = illness
            selectedIllness = nil
        }
    }
}

// MARK: - Table view data source

extension IllnessPickerViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return illnesses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: illnessCell, for: indexPath)
        let illness = illnesses[indexPath.row]
        cell.textLabel?.text = illness.name
        return cell
    }
}

// MARK: - Table view delegate

extension IllnessPickerViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIllness = illnesses[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "Register", sender: self)
    }
}

// MARK: - Fetched results controller delegate

extension IllnessPickerViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.reloadData()
    }
}
