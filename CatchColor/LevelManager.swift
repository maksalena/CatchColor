//
//  LevelManager.swift
//  CatchColor
//
//  Created by Алёна Максимова on 23.09.2024.
//

import Foundation

class LevelManager {
    static func loadHighestLevel() -> Int {
        return UserDefaults.standard.integer(forKey: "highestLevel")
    }
    
    static func saveHighestLevel(_ level: Int) {
        UserDefaults.standard.set(level, forKey: "highestLevel")
    }
}
