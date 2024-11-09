import UIKit

final class MovieQuizViewController: UIViewController {
    
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var noButton: UIButton!
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactory = QuestionFactory()
    private var currentQuestion: QuizQuestion?
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        resetQuiz()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        disableButtons()
        animateButtonPress(sender)
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        if givenAnswer == currentQuestion.correctAnswer {
            correctAnswers += 1
        }
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        disableButtons()
        animateButtonPress(sender)
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        if givenAnswer == currentQuestion.correctAnswer {
            correctAnswers += 1
        }
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    private func setupView() {
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 0
    }
    
    private func resetQuiz() {
        currentQuestionIndex = 0
        correctAnswers = 0
        if let firstQuestion = questionFactory.requestNextQuestion() {
            currentQuestion = firstQuestion
            let viewModel = convert(model: firstQuestion)
            show(quiz: viewModel)
            enableButtons()
        }
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    private func show(quiz step: QuizStepViewModel) {
        self.imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
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
            let alert = UIAlertController(
                title: "Поздравляем, вы ответили на 10 из 10!",
                message: "Вы ответили правильно на \(correctAnswers) из 10, попробуйте еще раз!",
                preferredStyle: .alert
            )
            let action = UIAlertAction(title: "Начать заново", style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                if let firstQuestion = self.questionFactory.requestNextQuestion() {
                    let viewModel = self.convert(model: firstQuestion)
                    self.show(quiz: viewModel)
                    self.enableButtons()
                }
            }
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        } else {
            currentQuestionIndex += 1
            if let nextQuestion = questionFactory.requestNextQuestion() {
                currentQuestion = nextQuestion
                let viewModel = convert(model: nextQuestion)
                enableButtons()
                show(quiz: viewModel)
            }
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
    
    private func showFireworksAnimation() {
        let fireworksEmitter = CAEmitterLayer()
        fireworksEmitter.emitterPosition = CGPoint(x: view.bounds.width / 2, y: -50)
        fireworksEmitter.emitterSize = CGSize(width: view.bounds.width, height: 0)
        fireworksEmitter.emitterShape = .line
        let cell = CAEmitterCell()
        cell.contents = UIImage(systemName: "circle.fill")?.cgImage
        cell.color = UIColor.systemPink.cgColor
        cell.birthRate = 6
        cell.lifetime = 4.0
        cell.velocity = 300
        cell.velocityRange = 100
        cell.emissionLongitude = .pi
        cell.emissionRange = .pi / 4
        cell.scale = 0.1
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
