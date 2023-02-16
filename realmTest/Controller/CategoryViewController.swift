//
//  CategoryViewController.swift
//  realmTest
//
//  Created by Марк Голубев on 13.02.2023.
//

import UIKit
import RealmSwift

class CategoryViewController: UITableViewController {
    
    // create instanse of Realm
    let realm = try! Realm()
    
    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationController?.navigationBar.barTintColor = .purple
        self.navigationItem.backButtonTitle = "Category"
        
    }
    
    
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
    //
    //        // MARK: - CRUD for Realm
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.image = UIImage(systemName: "puzzlepiece.fill")
        content.text = categories?[indexPath.row].name ?? "No category added"
        cell.contentConfiguration = content
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItemsSegue", sender: self)
    }
    
    // add delete cell functional
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let category = categories?[indexPath.row] {
                do {
                    try realm.write({
                        realm.delete(category.items)
                        realm.delete(category)
                    })
                } catch {
                    print("error updating done status \(error.localizedDescription)")
                }
            }
            tableView.deleteRows(at: [indexPath], with: .bottom)
        }
    }
    
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
