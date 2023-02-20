//
//  CategoryViewController.swift
//  realmTest
//
//  Created by Марк Голубев on 13.02.2023.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    // create instanse of Realm
    let realm = try! Realm()
    
    var categories: Results<Category>?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // this block for set up navigation bar
        guard let navBar = navigationController?.navigationBar else { return }
        
        navBar.tintColor = UIColor.white
        
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.blue
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navBar.standardAppearance = appearance
        navBar.scrollEdgeAppearance = appearance
        navigationItem.backButtonTitle = "Category"
        title = "ToDoList"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
        
    }
    
    // MARK: - Action controllers
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        // created controller
        alertAddEntity(title: "Add new category") {[self] category in
            let newCategory = Category()
            newCategory.name = category
            save(category: newCategory)
            tableView.reloadData()
        }
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
    
    // I created this function in SwipeTableViewController (superclass) for deleting category
    override func updateModel(at indexPath: IndexPath) {
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
    }
    
    // I created this function in SwipeTableViewController (superclass) for changing category name
    // I also create extension for UITableView for alerts
    override func updateName(at indexPath: IndexPath) {
        let oldName = categories?[indexPath.row].name ?? ""
        alertUpdateName(indexPath: indexPath, title: "Update category name", oldName: oldName) { [weak self] newName in
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
    }
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        var content = cell.defaultContentConfiguration()
        content.image = UIImage(systemName: "puzzlepiece.fill")
        content.text = categories?[indexPath.row].name ?? "No category added"
        if let color = UIColor(hexString: (categories?[indexPath.row].color)!) {
            cell.backgroundColor = color
            content.textProperties.color = ContrastColorOf(color, returnFlat: true)
        }
        cell.backgroundColor = UIColor(hexString: categories?[indexPath.row].color ?? UIColor.randomFlat().hexValue())
        cell.contentConfiguration = content
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItemsSegue", sender: self)
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



