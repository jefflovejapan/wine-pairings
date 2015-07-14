//
//  SelectionViewController.swift
//  wine-pairings
//
//  Created by Jeffrey Blagdon on 7/12/15.
//  Copyright (c) 2015 Jeffrey Blagdon. All rights reserved.
//

import UIKit

typealias FilterClosure = Varietal -> Bool
typealias FilterClosureGenerator = String -> FilterClosure
typealias CompletionClosure = String -> Void

class SelectionViewController: UIViewController {
    
    var completionFunc: CompletionClosure?
    
    var maybeChoices: [String]?
    lazy var tableView = { UITableView() }()
    
    let CELL_IDENTIFIER = "cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: CELL_IDENTIFIER)
        view.backgroundColor = UIColor.cyanColor()
        view.setNeedsUpdateConstraints()
    }
    
    override func updateViewConstraints() {
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[tlg][table]|", options: .allZeros, metrics: nil, views: ["tlg": topLayoutGuide, "table": tableView]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[table]|", options: .allZeros, metrics: nil, views: ["table": tableView]))
        super.updateViewConstraints()
    }
}

extension SelectionViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        if let completion = completionFunc, text = cell.textLabel?.text?.lowercaseString {
            completion(text)
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
}

extension SelectionViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return maybeChoices?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let maybeCell = tableView .dequeueReusableCellWithIdentifier(CELL_IDENTIFIER) as? UITableViewCell
        if let cell = maybeCell, choices = maybeChoices {
            cell.textLabel?.text = choices[indexPath.row].capitalizedString
            return cell
        }
        return UITableViewCell()
    }
}
