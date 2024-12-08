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
}
