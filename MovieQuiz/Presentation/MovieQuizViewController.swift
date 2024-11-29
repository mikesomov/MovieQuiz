import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    
    // MARK: - Lifecycle
    
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var alertPresenter: AlertPresenter?
    private var statisticService = StatisticService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 0
        
        showLoadingIndicator()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        statisticService = StatisticService()
        alertPresenter = AlertPresenter(delegate: self)
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
        
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    // MARK: - AlertPresenterDelegate
    
    func presentAlert(alert: UIAlertController) {
        present(alert, animated: true, completion: nil)
    }
    
    func alertActionCompleted() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
        enableButtons()
    }
    
    // MARK: - Actions
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        disableButtons()
        animateButtonPress(sender)
        handleAnswer(givenAnswer: true)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        disableButtons()
        animateButtonPress(sender)
        handleAnswer(givenAnswer: false)
    }
    
    // MARK: - Private functions
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: model.image,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    private func show(quiz step: QuizStepViewModel) {
        self.imageView.image = UIImage(data: step.image) ?? UIImage(named: "placeholder")
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func handleAnswer(givenAnswer: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        if givenAnswer == currentQuestion.correctAnswer {
            correctAnswers += 1
        }
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.imageView.layer.borderWidth = 0
            self.showNextQuestionOrResult()
        }
    }
    
    private func showNextQuestionOrResult() {
        if currentQuestionIndex == questionsAmount - 1 {
            showFireworksAnimation()
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
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
            enableButtons()
        }
    }
    
    private func disableButtons() {
        yesButton.isUserInteractionEnabled = false
        noButton.isUserInteractionEnabled = false
    }
    
    private func enableButtons() {
        self.yesButton.isUserInteractionEnabled = true
        self.noButton.isUserInteractionEnabled = true
    }
    
    private func showLoadingIndicator() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.isHidden = false
            self?.activityIndicator.startAnimating()
        }
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        let alertModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз") {
                [weak self] in
                guard let self = self else { return }
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                self.questionFactory?.requestNextQuestion()
                self.enableButtons()
            }
        alertPresenter?.showAlert(with: alertModel)
    }
    
    private func showFireworksAnimation() {
        let fireworksEmitter = CAEmitterLayer()
        fireworksEmitter.emitterPosition = CGPoint(x: view.bounds.width / 2, y: -50)
        fireworksEmitter.emitterSize = CGSize(width: view.bounds.width, height: 0)
        fireworksEmitter.emitterShape = .line
        
        let cell = CAEmitterCell()
        
        let customImage = UIImage(named: "peka")
        cell.contents = customImage?.cgImage
        
        cell.birthRate = 300
        cell.lifetime = 4.0
        cell.velocity = 300
        cell.velocityRange = 100
        cell.emissionLongitude = .pi
        cell.emissionRange = .pi / 4
        cell.scale = 0.02
        cell.scaleRange = 0.05
        cell.alphaSpeed = -0.1
        cell.yAcceleration = 150
        cell.spin = 2
        cell.spinRange = 3
        
        fireworksEmitter.emitterCells = [cell]
        view.layer.addSublayer(fireworksEmitter)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            fireworksEmitter.removeFromSuperlayer()
        }
    }
}

private func animateButtonPress(_ button: UIButton) {
    UIView.animate(withDuration: 0.1,
                   animations: {
        button.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
    },
                   completion: { _ in
        UIView.animate(withDuration: 0.1) {
            button.transform = CGAffineTransform.identity
        }
    })
}
