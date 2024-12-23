//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by MIKHAIL SOMOV on 14.11.2024.
//

import Foundation

final class StatisticService: StatisticServiceProtocol {
    private let storage: UserDefaults = .standard
    
    private enum Keys: String {
        case gamesCount
        case bestGameCorrect
        case bestGameTotal
        case bestGameDate
        case correctAnswers
        case totalQuestions
    }
    
    var gamesCount: Int {
        get { return storage.integer(forKey: Keys.gamesCount.rawValue) }
        set { storage.set(newValue, forKey: Keys.gamesCount.rawValue) }
    }
    
    var bestGame: GameResult {
        get {
            let correctAnswers = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            let totalQuestions = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            let date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            
            return GameResult(correct: correctAnswers, total: totalQuestions, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        let correctAnswers = storage.integer(forKey:Keys.correctAnswers.rawValue)
        let totalQuestions = storage.integer(forKey: Keys.totalQuestions.rawValue)
        
        guard totalQuestions > 0 else { return 0 }
        
        return Double(correctAnswers) / Double(totalQuestions) * 100
    }
    
    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        
        let updatedCorrectAnswers = storage.integer(forKey: Keys.correctAnswers.rawValue) + count
        let updatedTotalQuestions = storage.integer(forKey: Keys.totalQuestions.rawValue) + amount
        
        storage.set(updatedCorrectAnswers, forKey: Keys.correctAnswers.rawValue)
        storage.set(updatedTotalQuestions, forKey: Keys.totalQuestions.rawValue)
        
        let currentGame = GameResult(correct: count, total: amount, date: Date())
        if currentGame.isBestScore(bestGame) {
            bestGame = currentGame
        }
    }
}
