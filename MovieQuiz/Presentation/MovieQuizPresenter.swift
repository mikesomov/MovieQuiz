//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Mike Somov on 07.12.2024.
//

import Foundation
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    // MARK: - Lifecycle

    private weak var viewController: MovieQuizViewController?
    private var questionFactory: QuestionFactoryProtocol?
    var currentQuestion: QuizQuestion?
    var correctAnswers = 0
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        
        let questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: nil)
        self.questionFactory = questionFactory
        questionFactory.delegate = self
        questionFactory.loadData()
    }
    
    // MARK: - Internal Functions
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            print("Received nil question.")
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }

    func didLoadDataFromServer() {
        DispatchQueue.main.async { [weak self] in
            print("Data loaded from server.")
            self?.viewController?.hideLoadingIndicator()
            self?.requestNextQuestion()
        }
    }

    func didFailToLoadData(with error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.hideLoadingIndicator()
            self?.viewController?.showNetworkError(message: error.localizedDescription)
        }
    }

    func requestNextQuestion() {
        questionFactory?.requestNextQuestion()
    }

    func yesButtonClicked() {
        viewController?.disableButtons()
        viewController?.animateButtonPress(viewController?.yesButton ?? UIButton())
        handleAnswer(givenAnswer: true)
    }

    func noButtonClicked() {
        viewController?.disableButtons()
        viewController?.animateButtonPress(viewController?.noButton ?? UIButton())
        handleAnswer(givenAnswer: false)
    }

    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }

    func resetQuestionIndex() {
        currentQuestionIndex = 0
        correctAnswers = 0
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

    func handleAnswer(givenAnswer: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        let isCorrect = givenAnswer == currentQuestion.correctAnswer
        if isCorrect {
            correctAnswers += 1
        }
        viewController?.showAnswerResult(isCorrect: isCorrect)
    }

    func showNextQuestionOrResult(statisticService: StatisticService, alertPresenter: AlertPresenter?) {
        if isLastQuestion() {
            viewController?.showFireworksAnimation()
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            
            let gamesCount = statisticService.gamesCount
            let bestGame = statisticService.bestGame
            let accuracy = statisticService.totalAccuracy
            
            alertPresenter?.showFinalResultsAlert(
                correctAnswers: correctAnswers,
                totalQuestions: questionsAmount,
                gamesCount: gamesCount,
                bestGame: bestGame,
                accuracy: accuracy
            )
        } else {
            switchToNextQuestion()
            requestNextQuestion()
            viewController?.enableButtons()
        }
    }
}
