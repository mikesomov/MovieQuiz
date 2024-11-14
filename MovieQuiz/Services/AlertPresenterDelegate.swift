//
//  AlertPresenterProtocol.swift
//  MovieQuiz
//
//  Created by MIKHAIL SOMOV on 10.11.2024.
//

import Foundation
import UIKit

protocol AlertPresenterDelegate: AnyObject {
    func presentAlert(alert: UIAlertController)
    func alertActionCompleted()
}
