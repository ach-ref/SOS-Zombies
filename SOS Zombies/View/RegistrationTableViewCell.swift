//
//  RegistrationTableViewCell.swift
//  SOS Zombies
//
//  Created by Achref Marzouki on 22/4/21.
//

import UIKit

class RegistrationTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var lastUpdatedLabel: UILabel!
    @IBOutlet weak var illnessLabel: UILabel!
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configure()
    }

    // MARK: - UI
    
    private func configure() {
        userNameLabel.text = "--"
        lastUpdatedLabel.text = "--"
        illnessLabel.text = "--"
    }
    
    func setupContent(registration: Registration) {
        userNameLabel.text = registration.user?.name ?? "--"
        lastUpdatedLabel.text = registration.registrationDate
        illnessLabel.text = registration.illness?.name ?? "--"
    }
}
