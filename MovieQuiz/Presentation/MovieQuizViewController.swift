import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    
    // MARK: - Lifecycle
    
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    
    private var questionFactory: QuestionFactoryProtocol?
    private var correctAnswers = 0
    private var alertPresenter: AlertPresenter?
    private var statisticService = StatisticService()
    private lazy var presenter: MovieQuizPresenter = {
        return MovieQuizPresenter(viewController: self)
    }()
    
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
            presenter.didReceiveNextQuestion(question: question)
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
        if presenter.isLastQuestion() {
            presenter.resetQuestionIndex()
            correctAnswers = 0
            questionFactory?.requestNextQuestion()
            enableButtons()
        }
    }
    
    // MARK: - Actions
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    // MARK: - Private functions
    
    func show(quiz step: QuizStepViewModel) {
        self.imageView.image = UIImage(data: step.image) ?? UIImage(named: "placeholder")
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func handleAnswer(givenAnswer: Bool) {
        guard let currentQuestion = presenter.currentQuestion else {
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
            self.presenter.showNextQuestionOrResult(
                correctAnswers: self.correctAnswers,
                statisticService: self.statisticService,
                alertPresenter: self.alertPresenter
            )
        }
    }
    
    func requestNextQuestion() {
        questionFactory?.requestNextQuestion()
    }
    
    func disableButtons() {
        yesButton.isUserInteractionEnabled = false
        noButton.isUserInteractionEnabled = false
    }
    
    func enableButtons() {
        self.yesButton.isUserInteractionEnabled = true
        self.noButton.isUserInteractionEnabled = true
    }
    
    func animateButtonPress(_ button: UIButton) {
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
                if presenter.isLastQuestion() {
                    self.correctAnswers = 0
                    self.questionFactory?.requestNextQuestion()
                    self.enableButtons()
                }
            }
        alertPresenter?.showAlert(with: alertModel)
    }
    
    func showFireworksAnimation() {
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


