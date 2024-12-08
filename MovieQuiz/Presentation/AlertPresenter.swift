//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by MIKHAIL SOMOV on 10.11.2024.
//

import Foundation
import UIKit

final class AlertPresenter {
    
    private weak var delegate: AlertPresenterDelegate?
    
    init(delegate: AlertPresenterDelegate) {
        self.delegate = delegate
    }
    
    func showAlert(with model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
        alert.view.accessibilityIdentifier = "GameResultAlert"
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
    
    func showFinalResultsAlert(correctAnswers: Int, totalQuestions: Int, gamesCount: Int, bestGame: GameResult, accuracy: Double) {
        let alertModel = AlertModelBuilder.buildFinalResultsAlert(
            correctAnswers: correctAnswers,
            totalQuestions: totalQuestions,
            gamesCount: gamesCount,
            bestGame: bestGame,
            accuracy: accuracy,
            completion: { [weak self] in
                self?.delegate?.alertActionCompleted()
            }
        )
        showAlert(with: alertModel)
    }
}
