//
//  String+Trimmed.swift
//  SOS Zombies
//
//  Created by Achref Marzouki on 21/4/21.
//

import Foundation

extension String {
    
    func trimmed() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
