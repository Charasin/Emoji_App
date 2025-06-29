import UIKit

class MainViewController: UIViewController {
    @IBAction func startOfflineGame(_ sender: UIButton) {
        performSegue(withIdentifier: "startGame", sender: nil)
    }

    @IBAction func startOnlineGame(_ sender: UIButton) {
        PuzzleService.shared.fetchPuzzles { puzzles in
            puzzles.forEach { DatabaseManager.shared.insertPuzzle($0) }
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "startGame", sender: nil)
            }
        }
    }
}
