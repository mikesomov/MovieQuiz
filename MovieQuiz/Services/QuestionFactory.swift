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
    weak var delegate: QuestionFactoryDelegate?
    private var movies: [MostPopularMovie] = []

    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }

    func loadData() {
        print("Loading data from server...")
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    print("Movies loaded successfully.")
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    print("Failed to load movies. Error: \(error)")
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }

    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            print("Fetching next question...")
            
            let index = (0..<self.movies.count).randomElement() ?? 0
            guard let movie = self.movies[safe: index] else {
                print("Movie data is invalid.")
                return
            }

            var imageData = Data()
            do {
                print("Attempting to load image from URL: \(movie.resizedImageURL)")
                imageData = try Data(contentsOf: movie.resizedImageURL)

                if imageData.isEmpty {
                    print("Image data is empty.")
                    return
                }
            } catch {
                print("Failed to load image. Error: \(error)")
                return
            }

            let rating = Float(movie.rating) ?? 0
            let text = "Рейтинг этого фильма больше, чем 7?"
            let correctAnswer = rating > 7

            let question = QuizQuestion(image: imageData, text: text, correctAnswer: correctAnswer)
            print("Next question created: \(question.text)")

            DispatchQueue.main.async { [weak self] in
                self?.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
}
