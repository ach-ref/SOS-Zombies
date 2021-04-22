//
//  RegisterViewController.swift
//  SOS Zombies
//
//  Created by Achref Marzouki on 21/4/21.
//

import UIKit

class RegisterViewController: UIViewController {

    // MARK: - IBOutlets
    
    @IBOutlet private weak var illnessLabel: UILabel!
    @IBOutlet private weak var formContainerView: UIView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var insuranceIDLabel: UILabel!
    @IBOutlet private weak var insuranceIDTextField: UITextField!
    @IBOutlet private weak var painLevelLabel: UILabel!
    @IBOutlet private weak var painLevelSegmentedControl: UISegmentedControl!
    @IBOutlet private weak var errorLabel: UILabel!
    @IBOutlet private weak var doneButton: UIButton!
    
    // MARK: - Properties
    
    private weak var currentTextField: UITextField?
    private var registration: Registration!
    
    var illness: Illness!
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // initial settings
        configureView()
        registerForNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // focus the name field - make it easier for the user
        if nameTextField.canBecomeFirstResponder {
            nameTextField.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // remove the back button's title
        let backButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backButton
    }
    
    // MARK: - Deinit
    
    deinit {
        unregisterForNotifications()
    }

    // MARK: - UI
    
    private func configureView() {
        // navigation bar
        title = NSLocalizedString("register.title", comment: "")
        // form container view
        formContainerView.layer.cornerRadius = 10
        formContainerView.layer.borderWidth = 1
        if #available(iOS 13.0, *) {
            formContainerView.layer.borderColor = UIColor.tertiaryLabel.cgColor
        } else {
            let color = UIColor(red: 60/255.0, green: 60/255.0, blue: 60/255.0, alpha: 0.3)
            formContainerView.layer.borderColor = color.cgColor
        }
        // form
        illnessLabel.text = illness.name
        nameLabel.text = NSLocalizedString("register.name", comment: "")
        nameTextField.placeholder = NSLocalizedString("register.namePlaceholder", comment: "")
        nameTextField.delegate = self
        insuranceIDLabel.text = NSLocalizedString("register.insuranceID", comment: "")
        insuranceIDTextField.placeholder = NSLocalizedString("register.insuranceIDPlaceholder", comment: "")
        insuranceIDTextField.delegate = self
        painLevelLabel.text = NSLocalizedString("register.selectPainLevel", comment: "")
        errorLabel.text = " "
        doneButton.setTitle(NSLocalizedString("register.done", comment: ""), for: .normal)
        doneButton.setTitleColor(UIColor(named: "Primary"), for: .normal)
    }
    
    private func finishRegistration() {
        let context = CoreDataManager.shared.managedContext
        let painLevel = painLevelSegmentedControl.selectedSegmentIndex
        registration.lastUpdated = Date()
        registration.painLevel = Int16(painLevel)
        context.saveContext()
        
        // notify changes
        NotificationCenter.default.post(name: .userDidUpdateRegistration, object: nil)
        
        // show suggested hospitals
        performSegue(withIdentifier: "Hospitals", sender: self)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Hospitals" {
            let viewController = segue.destination as! HospitalsViewController
            viewController.registration = registration
        }
    }
    
    // MARK: - Actions
    
    @IBAction private func doneButtonTapped(_ sender: UIButton) {
        let error = formValidationError()
        guard error == nil else {
            doneButton.shake()
            errorLabel.text = error
            return
        }
        
        errorLabel.text = " "
        let userName = nameTextField.text!
        let insuranceID = insuranceIDTextField.text
        let illnessName = illness.name ?? ""
        
        let context = CoreDataManager.shared.managedContext
        let user = User.getUserNamed(userName, in: context)
        user.insuranceID = insuranceID
        let registrationInfo = user.registration(forIllness: illness, in: context)
        if !registrationInfo.isNew {
            let title = NSLocalizedString("register.existingRegistration", comment: "")
            let message = String(format: NSLocalizedString("register.existingRegistrationMessage", comment: ""), illnessName, userName)
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
            alertController.view.tintColor = UIColor(named: "Secondary")
            alertController.popoverPresentationController?.sourceView = view
            alertController.popoverPresentationController?.sourceRect = doneButton.frame.insetBy(dx: -8, dy: -8)
            alertController.popoverPresentationController?.permittedArrowDirections = [.up, .down]
            // continue
            let continueAction = UIAlertAction(title: NSLocalizedString("general.continue", comment: ""), style: .default) { _ in
                self.registration = registrationInfo.registration
                self.finishRegistration()
            }
            alertController.addAction(continueAction)
            // cancel
            let cancelAction = UIAlertAction(title: NSLocalizedString("general.cancel", comment: ""), style: .cancel)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
            // abort
            let abortAction = UIAlertAction(title: NSLocalizedString("general.abort", comment: ""), style: .destructive) { _ in
                context.reset()
                context.saveContext()
                self.view.endEditing(true)
                self.navigationController?.popViewController(animated: true)
            }
            alertController.addAction(abortAction)
        } else {
            registration = registrationInfo.registration
            finishRegistration()
        }
    }
    
    // MARK: - Notifications
    
    private func registerForNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIControl.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIControl.keyboardWillHideNotification,
                                               object: nil)
    }
    
    private func unregisterForNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Helpers
    
    private func formValidationError() -> String? {
        let name = (nameTextField.text ?? "").trimmed()
        guard !name.isEmpty else {
            return NSLocalizedString("register.nameRequired", comment: "")
        }
        
        return nil
    }
}

// MARK: - Text field delegate

extension RegisterViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == nameTextField {
            insuranceIDTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        currentTextField = nil
    }
}

// MARK: - Keyboard management

extension RegisterViewController {
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let textField = currentTextField,
              let nsValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        
        let keyboardHeight = nsValue.cgRectValue.height
        let bottomEdge = view.frame.height - keyboardHeight - view.safeAreaInsets.bottom
        let textFieldRect = formContainerView.convert(textField.frame, to: view)
        if textFieldRect.maxY > bottomEdge {
            let delta = textFieldRect.maxY - bottomEdge + 20
            var duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0
            duration = max(duration, 0.25)
            UIView.animate(withDuration: duration) {
                self.view.frame.origin.y = -delta
            }
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        var duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0
        duration = max(duration, 0.25)
        UIView.animate(withDuration: duration) {
            self.view.frame.origin.y = 0
        }
    }
}
