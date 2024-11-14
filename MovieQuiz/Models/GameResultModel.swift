//
//  GameResultModel.swift
//  MovieQuiz
//
//  Created by MIKHAIL SOMOV on 14.11.2024.
//

import Foundation

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    
    func isBetterThan(_ another: GameResult) -> Bool {
        correct > another.correct
    }
    
    var formattedDate: String {
        date.dateTimeString
    }
}
