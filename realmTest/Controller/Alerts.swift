//
//  Alerts.swift
//  realmTest
//
//  Created by Марк Голубев on 17.02.2023.
//

import UIKit

extension UITableViewController {
    
    // MARK: - Update name alert
    
    func alertUpdateName(indexPath: IndexPath, title: String, oldName: String, completionHandler: @escaping (String) -> Void) {
        // created controller
        let ac = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        // added TextField
        ac.addTextField()
        ac.textFields?.first?.text = oldName
        
        
        // created update button
        let updateAction = UIAlertAction(title: "Update", style: .default) {
            // trying to avoid strong reference
            [weak ac] action in
            // checked textField is not nil
            guard let newName = ac?.textFields?.first?.text, newName != "" else { return }
            completionHandler(newName)

        }
        
        // created dismis button
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) {
            // trying to avoid strong reference
            [weak self] _ in
            self?.tableView.reloadData()
        }
        
        ac.addAction(updateAction)
        ac.addAction(cancelAction)
        present(ac, animated: true)
    }
    
    // MARK: - Add entity alert
    
    func alertAddEntity(title: String, completionHandler: @escaping (String) -> Void) {
        let ac = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        // added TextField
        ac.addTextField()
//        ac.textFields?[0].placeholder = "Create new Category"
        
        
        // created action button
        let addAction = UIAlertAction(title: "Add", style: .default) {
            // trying to avoid strong reference
            [weak ac] action in
            // checked textField is not nil
            guard let entity = ac?.textFields?[0].text, entity != "" else { return }
            // use button Submit using answer and method out of closure
            completionHandler(entity)
        }
        
        // created dismis button
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) {
            // trying to avoid strong reference
            [weak self] _ in
            self?.tableView.reloadData()
        }
        
        ac.addAction(addAction)
        ac.addAction(cancelAction)
        present(ac, animated: true)
    }
    
}
