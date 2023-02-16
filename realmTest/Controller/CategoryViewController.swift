//
//  CategoryViewController.swift
//  realmTest
//
//  Created by Марк Голубев on 13.02.2023.
//

import UIKit
import RealmSwift
import SwipeCellKit

class CategoryViewController: UITableViewController {
    
    // create instanse of Realm
    let realm = try! Realm()
    
    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80.0
        loadCategories()
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.barTintColor = .purple
        self.navigationItem.backButtonTitle = "Category"
        
    }
    
    // MARK: - Action controllers
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        // created controller
        let ac = UIAlertController(title: "Add Category to your to do list", message: nil, preferredStyle: .alert)
        // added TextField
        ac.addTextField()
        ac.textFields?[0].placeholder = "Create new Category"
        
        
        // created action button
        let addAction = UIAlertAction(title: "Add Category", style: .default) {
            // trying to avoid strong reference
            [weak self, weak ac] action in
            // checked textField is not nil
            guard let category = ac?.textFields?[0].text, category != "" else { return }
            // use button Submit using answer and method out of closure
            self?.submit(category)
        }
        
        ac.addAction(addAction)
        present(ac, animated: true)
    }
    
    // added submit function with word checking
    func submit(_ category: String) {
        
        let newCategory = Category()
        newCategory.name = category
        //        categoryArray.insert(newCategory, at: 0)
        save(category: newCategory)
        tableView.reloadData()
        
        // update one row
        //        let indexPath = IndexPath(row: 0, section: 0)
        //        self.tableView.insertRows(at: [indexPath], with: .automatic)
        return
    }
    
    func updateAC(indexPath: IndexPath) {
        // created controller
        let ac = UIAlertController(title: "Update category name", message: nil, preferredStyle: .alert)
        // added TextField
        ac.addTextField()
        ac.textFields?[0].text = categories?[indexPath.row].name
        
        
        // created update button
        let updateAction = UIAlertAction(title: "Update", style: .default) {
            // trying to avoid strong reference
            [weak self, weak ac] action in
            // checked textField is not nil
            guard let newName = ac?.textFields?[0].text, newName != "" else { return }
            // use button Submit using answer and method out of closure
            if let category = self?.categories?[indexPath.row] {
                do {
                    try self?.realm.write({
                        category.name = newName
                    })
                } catch {
                    print("error updating done status \(error.localizedDescription)")
                }
                self?.tableView.reloadData()
            }
        }
        
        // created dismis button
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) {
            // trying to avoid strong reference
            [weak self] action in
            // checked textField is not nil
            self?.tableView.reloadData()
            return
        }
        
        ac.addAction(updateAction)
        ac.addAction(cancelAction)
        present(ac, animated: true)
    }
    
    
    // MARK: - CRUD for Realm
    
    func save(category: Category) {
        
        do {
            try realm.write({
                realm.add(category)
            })
        } catch {
            print("Error save/add realm category object: \(error.localizedDescription)")
        }
        
    }
    
    
    func loadCategories() {
        
        categories = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    //    func deleteData(with indexPath: IndexPath) {
    //
    //        context.delete(categoryArray[indexPath.row])
    //        categoryArray.remove(at: indexPath.row)
    //
    //
    //    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! SwipeTableViewCell
        var content = cell.defaultContentConfiguration()
        content.image = UIImage(systemName: "puzzlepiece.fill")
        content.text = categories?[indexPath.row].name ?? "No category added"
        cell.contentConfiguration = content
        cell.delegate = self
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItemsSegue", sender: self)
    }
    
    // add delete cell functional
    //    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    //        if editingStyle == .delete {
    //            if let category = categories?[indexPath.row] {
    //                do {
    //                    try realm.write({
    //                        realm.delete(category.items)
    //                        realm.delete(category)
    //                    })
    //                } catch {
    //                    print("error updating done status \(error.localizedDescription)")
    //                }
    //            }
    //            tableView.deleteRows(at: [indexPath], with: .bottom)
    //        }
    //    }
    
    // MARK: - Navigation
    
    //  In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destinationVC = segue.destination as? ToDoListTableViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.selectedCategory = categories?[indexPath.row]
            }
        }
        
        
    }
    
    
}

// MARK: - SwipeTableViewCellDelegate

extension CategoryViewController: SwipeTableViewCellDelegate  {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let editAction = SwipeAction(style: .default, title: "Edit", handler: { action, indexPath in
            self.updateAC(indexPath: indexPath)
        })
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            if let category = self.categories?[indexPath.row] {
                do {
                    try self.realm.write({
                        self.realm.delete(category.items)
                        self.realm.delete(category)
                    })
                } catch {
                    print("error updating done status \(error.localizedDescription)")
                }
            }
//            tableView.deleteRows(at: [indexPath], with: .bottom)
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

