//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by MIKHAIL SOMOV on 09.11.2024.
//

import Foundation
import UIKit

protocol QuestionFactoryProtocol {
    func requestNextQuestion() -> QuizQuestion?
}
