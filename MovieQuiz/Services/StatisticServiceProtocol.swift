//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by MIKHAIL SOMOV on 14.11.2024.
//

import Foundation

protocol StatisticServiceProtocol {
    var gamesCount: Int { get }
    var bestGame: GameResult { get }
    var totalAccuracy: Double { get }
    
    func store(correct count: Int, total amount: Int)
}
