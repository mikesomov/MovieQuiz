import UIKit

final class MovieQuizViewController: UIViewController {
    
    // MARK: - Lifecycle
    
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    
    private var presenter: MovieQuizPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 0
        
        showLoadingIndicator()
        presenter = MovieQuizPresenter(viewController: self)
    }
    
    // MARK: - Internal Functions
    
    func setImageBorder(isCorrect: Bool) {
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func resetImageBorder() {
        imageView.layer.borderWidth = 0
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
    
    func show(quiz step: QuizStepViewModel) {
        DispatchQueue.main.async {
            self.imageView.image = UIImage(data: step.image) ?? UIImage(named: "placeholder")
            self.textLabel.text = step.question
            self.counterLabel.text = step.questionNumber
        }
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        let alertModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз"
        ) { [weak self] in
            guard let self = self else { return }
            if self.presenter.isLastQuestion() {
                self.presenter.correctAnswers = 0
                self.presenter.requestNextQuestion()
                self.enableButtons()
            }
        }
        presenter.alertPresenter?.showAlert(with: alertModel)
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            fireworksEmitter.removeFromSuperlayer()
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
    
    private func showLoadingIndicator() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.isHidden = false
            self?.activityIndicator.startAnimating()
        }
    }
}
