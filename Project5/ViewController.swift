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
        
    }
    
}

