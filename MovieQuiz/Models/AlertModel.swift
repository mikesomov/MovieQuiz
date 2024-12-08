//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by MIKHAIL SOMOV on 10.11.2024.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: (() -> Void)?
    
}

struct AlertModelBuilder {
    static func buildAlert(
        title: String,
        message: String,
        buttonText: String,
        completion: @escaping () -> Void
    ) -> AlertModel {
        return AlertModel(
            title: title,
            message: message,
            buttonText: buttonText,
            completion: completion
        )
    }
}
