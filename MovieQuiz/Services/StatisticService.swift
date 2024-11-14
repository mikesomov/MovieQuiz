//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by MIKHAIL SOMOV on 14.11.2024.
//

import Foundation

final class StatisticService {
    
    private let userDefaults = UserDefaults.standard
    
    private enum Keys: String {
        case gamesCount
        case bestGameCorrect
        case bestGameTotal
        case bestGameDate
        case totalAccuracy
    }
    
    var gamesCount: Int {
        get {
            return userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            let correct = userDefaults.integer(forKey: Keys.bestGameCorrect.rawValue)
            let total = userDefaults.integer(forKey: Keys.bestGameTotal.rawValue)
            let date = userDefaults.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            if newValue.isBetterThan(bestGame) {
                userDefaults.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
                userDefaults.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
                userDefaults.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
            }
        }
    }
    
    var totalAccuracy: Double {
        get {
            return userDefaults.double(forKey: Keys.totalAccuracy.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.totalAccuracy.rawValue)
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        let newAccuracy = (Double(count) / Double(amount)) * 100
        totalAccuracy = ((totalAccuracy * Double(gamesCount - 1)) + newAccuracy) / Double(gamesCount)
        
        let gameResult = GameResult(correct: count, total: amount, date: Date())
        bestGame = gameResult
    }
}
