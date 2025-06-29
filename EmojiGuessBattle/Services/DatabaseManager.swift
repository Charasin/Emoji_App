import Foundation
import SQLite3

class DatabaseManager {
    static let shared = DatabaseManager()
    private var db: OpaquePointer?

    private init() {
        openDatabase()
        createTables()
    }

    private func openDatabase() {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            .appendingPathComponent("puzzles.sqlite")
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Unable to open database")
        }
    }

    private func createTables() {
        let createPuzzleTable = """
        CREATE TABLE IF NOT EXISTS Puzzles (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            emoji TEXT UNIQUE,
            answer TEXT,
            hint TEXT
        );
        """
        let createResultTable = """
        CREATE TABLE IF NOT EXISTS Results (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userAnswer TEXT,
            isCorrect INTEGER
        );
        """
        execute(sql: createPuzzleTable)
        execute(sql: createResultTable)
    }

    private func execute(sql: String) {
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_step(stmt)
        }
        sqlite3_finalize(stmt)
    }

    func insertPuzzle(_ puzzle: EmojiPuzzle) {
        let insertSQL = "INSERT OR IGNORE INTO Puzzles (emoji, answer, hint) VALUES (?, ?, ?);"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, insertSQL, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, puzzle.emoji, -1, nil)
            sqlite3_bind_text(stmt, 2, puzzle.answer, -1, nil)
            sqlite3_bind_text(stmt, 3, puzzle.hint, -1, nil)
            sqlite3_step(stmt)
        }
        sqlite3_finalize(stmt)
    }

    func fetchRandomPuzzle() -> EmojiPuzzle? {
        let query = "SELECT emoji, answer, hint FROM Puzzles ORDER BY RANDOM() LIMIT 1;"
        var stmt: OpaquePointer?
        var puzzle: EmojiPuzzle?
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            if sqlite3_step(stmt) == SQLITE_ROW {
                let emoji = String(cString: sqlite3_column_text(stmt, 0))
                let answer = String(cString: sqlite3_column_text(stmt, 1))
                let hint = String(cString: sqlite3_column_text(stmt, 2))
                puzzle = EmojiPuzzle(emoji: emoji, answer: answer, hint: hint)
            }
        }
        sqlite3_finalize(stmt)
        return puzzle
    }

    func insertResult(answer: String, isCorrect: Bool) {
        let insertSQL = "INSERT INTO Results (userAnswer, isCorrect) VALUES (?, ?);"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, insertSQL, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, answer, -1, nil)
            sqlite3_bind_int(stmt, 2, isCorrect ? 1 : 0)
            sqlite3_step(stmt)
        }
        sqlite3_finalize(stmt)
    }
}
