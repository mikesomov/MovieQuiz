//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by MIKHAIL SOMOV on 07.11.2024.
//

import Foundation
import UIKit

final class QuestionFactory: QuestionFactoryProtocol {
    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    private var movies: [MostPopularMovie] = []
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate? = nil) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
            guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    func setup(delegate: QuestionFactoryDelegate) {
        self.delegate = delegate
    }
    
//    private let questions: [QuizQuestion] = [
//        QuizQuestion(
//            image: UIImage(named: "The Godfather") ?? UIImage(),
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true),
//        QuizQuestion(
//            image: UIImage(named: "The Dark Knight") ?? UIImage(),
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true),
//        QuizQuestion(
//            image: UIImage(named: "Kill Bill") ?? UIImage(),
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true),
//        QuizQuestion(
//            image: UIImage(named: "The Avengers") ?? UIImage(),
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true),
//        QuizQuestion(
//            image: UIImage(named: "Deadpool") ?? UIImage(),
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true),
//        QuizQuestion(
//            image: UIImage(named: "The Green Knight") ?? UIImage(),
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true),
//        QuizQuestion(
//            image: UIImage(named: "Old") ?? UIImage(),
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: false),
//        QuizQuestion(
//            image: UIImage(named: "The Ice Age Adventures of Buck Wild") ?? UIImage(),
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: false),
//        QuizQuestion(
//            image: UIImage(named: "Tesla") ?? UIImage(),
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: false),
//        QuizQuestion(
//            image: UIImage(named: "Vivarium") ?? UIImage(),
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: false)
//    ]
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                print("Failed to load image")
            }
            
            let rating = Float(movie.rating) ?? 0
            
            let text = "Рейтинг этого фильма больше, чем 7?"
            let correctAnswer = rating > 7
            
            let question = QuizQuestion(image: imageData,
                                        text: text,
                                        correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
}
