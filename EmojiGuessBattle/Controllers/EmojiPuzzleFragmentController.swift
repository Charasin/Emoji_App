import UIKit

protocol EmojiPuzzleDelegate: AnyObject {
    func didSubmitAnswer(_ answer: String)
}

class EmojiPuzzleFragmentController: UIViewController {
    @IBOutlet weak var emojiLabel: UILabel!
    @IBOutlet weak var answerTextField: UITextField!
    weak var delegate: EmojiPuzzleDelegate?

    func configure(with puzzle: EmojiPuzzle) {
        emojiLabel.text = puzzle.emoji
    }

    @IBAction func submitAnswer() {
        delegate?.didSubmitAnswer(answerTextField.text ?? "")
    }
}
