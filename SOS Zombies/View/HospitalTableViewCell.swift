//
//  HospitalTableViewCell.swift
//  SOS Zombies
//
//  Created by Achref Marzouki on 22/4/21.
//

import UIKit
import MapKit

class HospitalTableViewCell: UITableViewCell {

    // MARK: - IBOutlets
    
    @IBOutlet private weak var hospitalNameLabel: UILabel!
    @IBOutlet private weak var distanceValueLabel: UILabel!
    @IBOutlet private weak var waitingTimeLabel: UILabel!
    @IBOutlet private weak var waitingTimeValueLabel: UILabel!
    
    // MARK: - Private
    
    private lazy var numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initial settings
        configure()
    }
    
    override func prepareForReuse() {
        prepare()
    }

    // MARK: - UI
    
    private func configure() {
        prepare()
    }
    
    private func prepare() {
        hospitalNameLabel.text = "--"
        distanceValueLabel.text = "--"
        waitingTimeLabel.text = NSLocalizedString("hospitals.waitingTime", comment: "")
        waitingTimeValueLabel.text = "--"
    }
    
    func setupContent(hospital: Hospital, painLevel: Int16, userLocation: CLLocation?) {
        let (time, distance) = hospital.hospitalInfo(painLevel: painLevel, userLocation: userLocation)
        hospitalNameLabel.text = hospital.name
        let dist = distance == -1 ? "-- km" : String(format: "%@ km", numberFormatter.string(from: NSNumber(value: distance)) ?? "")
        distanceValueLabel.text = dist
        waitingTimeValueLabel.text = time.userFriendlyTime
    }
}
