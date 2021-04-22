//
//  RegistrationDetailTableViewCell.swift
//  SOS Zombies
//
//  Created by Achref Marzouki on 22/4/21.
//

import UIKit

class RegistrationDetailTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameValueLabel: UILabel!
    @IBOutlet weak var insuranceIDLabel: UILabel!
    @IBOutlet weak var insuranceIDValueLabel: UILabel!
    @IBOutlet weak var illnessLabel: UILabel!
    @IBOutlet weak var illnessValueLabel: UILabel!
    @IBOutlet weak var painLevelLabel: UILabel!
    @IBOutlet weak var painLevelValueLabel: UILabel!
    
    // MARK: - Licecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configure()
    }

    // MARK: - UI
    
    private func configure() {
        nameLabel.text = NSLocalizedString("register.name", comment: "")
        insuranceIDLabel.text = NSLocalizedString("register.insuranceID", comment: "")
        illnessLabel.text = NSLocalizedString("register.illness", comment: "")
        painLevelLabel.text = NSLocalizedString("register.painLevel", comment: "")
    }
    
    func setupContent(registration: Registration) {
        var insuranceID = registration.user?.insuranceID ?? "--"
        insuranceID = insuranceID.isEmpty ? "--" : insuranceID
        insuranceIDValueLabel.text = insuranceID
        nameValueLabel.text = registration.user?.name ?? "--"
        illnessValueLabel.text = registration.illness?.name ?? "--"
        painLevelValueLabel.text = String(format: "%02d", registration.painLevel)
    }
}
