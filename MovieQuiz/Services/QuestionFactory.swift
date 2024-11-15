//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by MIKHAIL SOMOV on 07.11.2024.
//

import Foundation
import UIKit

final class QuestionFactory: QuestionFactoryProtocol {
    
    private weak var delegate: QuestionFactoryDelegate?
    
    func setup(delegate: QuestionFactoryDelegate) {
        self.delegate = delegate
    }
    
    private let questions: [QuizQuestion] = [
        QuizQuestion(
            image: UIImage(named: "The Godfather") ?? UIImage(),
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: UIImage(named: "The Dark Knight") ?? UIImage(),
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: UIImage(named: "Kill Bill") ?? UIImage(),
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: UIImage(named: "The Avengers") ?? UIImage(),
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: UIImage(named: "Deadpool") ?? UIImage(),
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: UIImage(named: "The Green Knight") ?? UIImage(),
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: UIImage(named: "Old") ?? UIImage(),
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: UIImage(named: "The Ice Age Adventures of Buck Wild") ?? UIImage(),
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: UIImage(named: "Tesla") ?? UIImage(),
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: UIImage(named: "Vivarium") ?? UIImage(),
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false)
    ]
    
    func requestNextQuestion() {
        guard let index = (0..<questions.count).randomElement() else {
            delegate?.didReceiveNextQuestion(question: nil)
            return
        }
        let question = questions[index]
        delegate?.didReceiveNextQuestion(question: question)
    }
}
