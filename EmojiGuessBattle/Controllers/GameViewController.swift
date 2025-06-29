import UIKit

class GameViewController: UIViewController, EmojiPuzzleDelegate {
    private var currentPuzzle: EmojiPuzzle?
    private lazy var puzzleFragment = EmojiPuzzleFragmentController()
    private lazy var resultFragment = ResultFragmentController()

    override func viewDidLoad() {
        super.viewDidLoad()
        puzzleFragment.delegate = self
        addChild(puzzleFragment)
        puzzleFragment.view.frame = view.bounds
        view.addSubview(puzzleFragment.view)
        puzzleFragment.didMove(toParent: self)
        loadNextPuzzle()
    }

    func loadNextPuzzle() {
        if let puzzle = DatabaseManager.shared.fetchRandomPuzzle() {
            currentPuzzle = puzzle
            puzzleFragment.configure(with: puzzle)
        } else {
            PuzzleService.shared.fetchPuzzles { puzzles in
                puzzles.forEach { DatabaseManager.shared.insertPuzzle($0) }
                DispatchQueue.main.async {
                    if let puzzle = DatabaseManager.shared.fetchRandomPuzzle() {
                        self.currentPuzzle = puzzle
                        self.puzzleFragment.configure(with: puzzle)
                    }
                }
            }
        }
    }

    func didSubmitAnswer(_ answer: String) {
        guard let puzzle = currentPuzzle else { return }
        DispatchQueue.global().async {
            let correct = puzzle.answer.lowercased() == answer.lowercased()
            DatabaseManager.shared.insertResult(answer: answer, isCorrect: correct)
            DispatchQueue.main.async {
                self.showResult(isCorrect: correct)
            }
        }
    }

    private func showResult(isCorrect: Bool) {
        addChild(resultFragment)
        resultFragment.view.frame = view.bounds
        view.addSubview(resultFragment.view)
        resultFragment.didMove(toParent: self)
        resultFragment.configure(isCorrect: isCorrect)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.resultFragment.willMove(toParent: nil)
            self.resultFragment.view.removeFromSuperview()
            self.resultFragment.removeFromParent()
            self.loadNextPuzzle()
        }
    }
}
