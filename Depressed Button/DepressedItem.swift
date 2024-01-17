//
//  Item.swift
//  Depressed Button
//
//  Created by Helloyunho on 1/7/24.
//

import Foundation
import SwiftData

@Model
final class DepressedItem {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
