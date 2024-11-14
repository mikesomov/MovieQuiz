//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by MIKHAIL SOMOV on 10.11.2024.
//

import Foundation
import UIKit

final class AlertPresenter {
    
    weak var delegate: AlertPresenterDelegate?
    private let statisticService = StatisticService()
    
    init(delegate: AlertPresenterDelegate) {
        self.delegate = delegate
    }
    
    func showAlert(with model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
        let action = UIAlertAction(
            title: model.buttonText,
            style: .default
        ) { [weak self] _ in
            model.completion?()
            self?.delegate?.alertActionCompleted()
        }
        alert.addAction(action)
        delegate?.presentAlert(alert: alert)
    }
    
    func showFinalResultsAlert(correctAnswers: Int, totalQuestions: Int) {
        let gamesCount = statisticService.gamesCount
        let bestGame = statisticService.bestGame
        let accuracy = statisticService.totalAccuracy
        let alertMessage = """
             Ваш результат: \(correctAnswers)/\(totalQuestions)
             Количество сыгранных квизов: \(gamesCount)
             Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
             Средняя точность: \(String(format: "%.2f", accuracy))%
             """
        let alertModel = AlertModel (
            title: "Этот раунд окончен!",
            message: alertMessage,
            buttonText: "Сыграть еще раз",
            completion: { [weak self] in
                self?.delegate?.alertActionCompleted()
            }
        )
        showAlert(with: alertModel)
    }
}
