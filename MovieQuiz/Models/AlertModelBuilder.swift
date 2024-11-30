//
//  AlertModelBuilder.swift
//  MovieQuiz
//
//  Created by MIKHAIL SOMOV on 15.11.2024.
//

import Foundation

struct AlertModelBuilder {
    static func buildFinalResultsAlert(correctAnswers: Int, totalQuestions: Int, gamesCount: Int, bestGame: GameResult, accuracy: Double, completion: @escaping () -> Void) -> AlertModel {
        let alertMessage = """
            Ваш результат: \(correctAnswers)/\(totalQuestions)
            Количество сыгранных квизов: \(gamesCount)
            Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
            Средняя точность: \(String(format: "%.2f", accuracy))%
            """
        return AlertModel(
            title: "Этот раунд окончен!",
            message: alertMessage,
            buttonText: "Сыграть еще раз",
            completion: completion
        )
    }
}
