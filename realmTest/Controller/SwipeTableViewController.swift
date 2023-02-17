//
//  SwipeTableViewController.swift
//  realmTest
//
//  Created by Марк Голубев on 17.02.2023.
//

import UIKit
import SwipeCellKit

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
    }
    
    // MARK: - TableView DataSource
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell

        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let editAction = SwipeAction(style: .default, title: "Edit", handler: {[self] action, indexPath in
            updateName(at: indexPath)
        })
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") {[self] action, indexPath in
            // handle action by updating model with deletion
            updateModel(at: indexPath)

        }
        
        // customize the action appearance
        editAction.image = UIImage(systemName: "pencil")?.resized(to: CGSize(width: 35, height: 35))?.withTintColor(.white)
        editAction.backgroundColor = .orange
        deleteAction.image = UIImage(named: "delete-icon")
        
        return [deleteAction, editAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }
    
    func updateModel(at indexPath: IndexPath) {
        
    }
    
    func updateName(at indexPath: IndexPath) {
        
    }
    

}

// MARK: - UIImage resize method

extension UIImage {
    func resized(to size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
