import UIKit

class ResultFragmentController: UIViewController {
    @IBOutlet weak var resultLabel: UILabel!

    func configure(isCorrect: Bool) {
        resultLabel.text = isCorrect ? "Correct!" : "Wrong!"
    }
}
