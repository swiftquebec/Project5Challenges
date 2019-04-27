//
//  ViewController.swift
//  Project5
//
//  Created by Gregory Leck on 2019-04-24.
//  Copyright © 2019 Gregory Leck. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    var allWords = [String]()
    var usedWords = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add rightbar button item
        // To allow user to enter words
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        
        // Load start.txt and then convert it to an array
        // First, find the path
        // then fill the allWords array
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
            if allWords.isEmpty {
                allWords = ["silkworm"]
            }
        }
        
        startGame()
    }
    
    func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        // tableView property comes from UITableViewController
        tableView.reloadData()
    }
    
    // Number of Rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    // Display content of row
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    @objc func promptForAnswer() {
        // create prompt
        let ac = UIAlertController(title: "Enter Answer", message: nil, preferredStyle: .alert)
        // Add textfield to the alert
        ac.addTextField()
        // Use custom closure with trailing closure syntax
        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            // *weak* because both the alertcontroller and viewcontroller
            // are referenced in the trailing closure.
            // We don't want either "strongly" captured (i.e., a strong ref cycle)  .
            // Hence, they become optionals.
            [weak self, weak ac] _ in // Part after in signifies the body of the closure
            guard let answer = ac?.textFields?[0].text else { return }
            // *submit* is a method (see below)
            self?.submit(answer)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func submit(_ answer: String) {
        
        let lowerAnswer = answer.lowercased()
        
        let errorTitle: String
        let errorMessage: String
        
        
        if isPossible(word: lowerAnswer) {
            if isOriginal(word: lowerAnswer) {
                if isReal(word: lowerAnswer) {
                    usedWords.insert(answer, at: 0)
                    
                    // Inserting cell is easier than reloading
                    // In this case the new word will slide in from the top
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    
                    // if all conditions above are met, we'll exit the method:
                    return
                    
                } else {
                    errorTitle = "Word not recognized"
                    errorMessage = "You just can't make them up, you know!"
                }
            } else {
                errorTitle = "Word already used"
                errorMessage = "Be more original!"
            }
        } else {
            errorTitle = "Word not possible"
            errorMessage = "You can't spell that word from \(title!.lowercased())."
        }
        
        // Use UIAlertController to present alert message
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else { return false }
        
        for letter in word {
            // .firstIndex finds first instance of "letter"
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        // if it contains the word, return false
        return !usedWords.contains(word)
    }
    
    func isReal(word: String) -> Bool {
        
        // Use UITextChecker to check for spelling.
        // Has problems interacting with Swift, thus the repeated NS references.
        // Rule: If working with UIKit, etc., use utf16.count to count strings.
        let checker = UITextChecker()
        // range: scan full length of word
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        // If no spelling mistakes, the function returns true:
        return misspelledRange.location == NSNotFound
    }
    
}

