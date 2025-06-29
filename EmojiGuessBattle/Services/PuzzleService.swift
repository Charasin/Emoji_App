import Foundation

class PuzzleService {
    static let shared = PuzzleService()
    private let session: URLSession
    private let apiURL = URL(string: "https://example.com/api/puzzles")!

    private init() {
        let configuration = URLSessionConfiguration.default
        session = URLSession(configuration: configuration)
    }

    func fetchPuzzles(completion: @escaping ([EmojiPuzzle]) -> Void) {
        let task = session.dataTask(with: apiURL) { data, response, error in
            guard let data = data else {
                completion([])
                return
            }
            DispatchQueue.global().async {
                do {
                    let puzzles = try JSONDecoder().decode([EmojiPuzzle].self, from: data)
                    completion(puzzles)
                } catch {
                    completion([])
                }
            }
        }
        task.resume()
    }

    func startBackgroundFetching() {
        let backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "fetchPuzzles") {
            UIApplication.shared.endBackgroundTask(UIBackgroundTaskIdentifier.invalid)
        }
        fetchPuzzles { puzzles in
            puzzles.forEach { DatabaseManager.shared.insertPuzzle($0) }
            UIApplication.shared.endBackgroundTask(backgroundTask)
        }
    }
}
