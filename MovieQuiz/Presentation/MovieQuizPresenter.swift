//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Mike Somov on 07.12.2024.
//

import Foundation
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate, AlertPresenterDelegate {
    
    // MARK: - Lifecycle
    
    private weak var viewController: MovieQuizViewController?
    private var questionFactory: QuestionFactoryProtocol?
    var alertPresenter: AlertPresenter?
    var currentQuestion: QuizQuestion?
    var correctAnswers = 0
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var statisticService: StatisticService
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        self.statisticService = StatisticService()
        self.alertPresenter = AlertPresenter(delegate: self)
        
        let questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: nil)
        self.questionFactory = questionFactory
        questionFactory.delegate = self
        questionFactory.loadData()
    }
    
    // MARK: - Internal Functions
    
    func presentAlert(alert: UIAlertController) {
        viewController?.present(alert, animated: true, completion: nil)
    }
    
    func alertActionCompleted() {
        if isLastQuestion() {
            resetQuestionIndex()
            requestNextQuestion()
            viewController?.enableButtons()
        }
    }
    
    func proceedWithAnswer(isCorrect: Bool) {
        viewController?.setImageBorder(isCorrect: isCorrect)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.viewController?.resetImageBorder()
            self.proceedToNextQuestionOrResults()
        }
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
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
        didAnswer(givenAnswer: true)
    }
    
    func noButtonClicked() {
        viewController?.disableButtons()
        viewController?.animateButtonPress(viewController?.noButton ?? UIButton())
        didAnswer(givenAnswer: false)
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
    
    func didAnswer(givenAnswer: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        let isCorrect = givenAnswer == currentQuestion.correctAnswer
        if isCorrect {
            correctAnswers += 1
        }
        proceedWithAnswer(isCorrect: isCorrect)
    }
    
    func proceedToNextQuestionOrResults() {
        guard let alertPresenter = alertPresenter else {
            return
        }
        
        if isLastQuestion() {
            viewController?.showFireworksAnimation()
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            
            let gamesCount = statisticService.gamesCount
            let bestGame = statisticService.bestGame
            let accuracy = statisticService.totalAccuracy
            
            alertPresenter.showFinalResultsAlert(
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

func makeResultsMessage(
    correctAnswers: Int,
    totalQuestions: Int,
    gamesCount: Int,
    bestGame: GameResult,
    accuracy: Double,
    completion: @escaping () -> Void
) -> AlertModel {
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
