//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Mike Somov on 07.12.2024.
//

import Foundation
import UIKit

final class MovieQuizPresenter {
    
    private weak var viewController: MovieQuizViewController?
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
    }
    func yesButtonClicked() {
        viewController?.disableButtons()
        viewController?.animateButtonPress(viewController?.yesButton ?? UIButton())
        viewController?.handleAnswer(givenAnswer: true)
    }
    
    func noButtonClicked() {
        viewController?.disableButtons()
        viewController?.animateButtonPress(viewController?.noButton ?? UIButton())
        viewController?.handleAnswer(givenAnswer: false)
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: model.image,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
}
