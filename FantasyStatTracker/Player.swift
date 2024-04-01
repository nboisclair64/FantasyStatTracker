//
//  Player.swift
//  FantasyStatTracker
//
//  Created by NICHOLAS BOISCLAIR on 2024-03-28.
//

import Foundation
import SwiftUI

struct Player: Hashable, Codable, Identifiable{
    var name: String
    var id: Int
    var teamAbr: String
    var headshot: String
    var nextGameId: Int
    var pos: String
    var goals: Int
    var assists: Int
    var shots: Int
}
