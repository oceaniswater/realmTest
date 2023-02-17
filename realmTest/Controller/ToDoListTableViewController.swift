//
//  ToDoListTableViewController.swift
//  realmTest
//
//  Created by Марк Голубев on 13.02.2023.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ToDoListTableViewController: SwipeTableViewController {
    
    var items: Results<Item>?
    let realm = try! Realm()
    
    // search bar
    var searchController = UISearchController()
    
    var containsTitlePredicate = "title CONTAINS[cd] %@"
    
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UISearchController set up
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search here..."
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
    }
    
    // MARK: - Add new Item
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        alertAddEntity(title: "Add new item") { [self] item in
            let newItem = Item()
            newItem.title = item
            save(item: newItem)

            self.tableView.reloadData()
        }
        
    }
    
    // MARK: - CRUD for Realm
    
    func save(item: Item) {
        
        if let currentCategory = selectedCategory {
            do {
                try realm.write({
                    currentCategory.items.append(item)
                })
            } catch {
                print("Error save/add realm item object: \(error.localizedDescription)")
            }
        }
    }
    
    func loadItems() {
        
        items = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: false)
        
        tableView.reloadData()
    }
    
    // I created this function in SwipeTableViewController (superclass) for deleting category
    override func updateModel(at indexPath: IndexPath) {
        if let item = items?[indexPath.row] {
            do {
                try realm.write({
                    realm.delete(item)
                })
            } catch {
                print("error updating done status \(error.localizedDescription)")
            }
        }
    }
    
    
    // I created this function in SwipeTableViewController (superclass) for changing category name
    // I also create extension for UITableView for alerts
    override func updateName(at indexPath: IndexPath) {
        let oldName = items?[indexPath.row].title ?? ""
        alertUpdateName(indexPath: indexPath, title: "Update item name", oldName: oldName) {[weak self] newName in
            if let item = self?.items?[indexPath.row] {
                do {
                    try self?.realm.write({
                        item.title = newName
                    })
                } catch {
                    print("error updating title \(error.localizedDescription)")
                }
                self?.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Table view data source and delegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return items?.count ?? 1
    }
    
    // setup cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        var content = cell.defaultContentConfiguration()
        content.image = UIImage(systemName: "applelogo")
        if let item = items?[indexPath.row] {
            content.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
            
            if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(items!.count)) {
                cell.backgroundColor = color
                content.textProperties.color = ContrastColorOf(color, returnFlat: true)
            }
            
            
        } else {
            content.text = "No added items"
        }
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = items?[indexPath.row] {
            do {
                try realm.write({
                    item.done = !item.done
                })
            } catch {
                print("error updating done status \(error.localizedDescription)")
            }
            tableView.reloadData()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}



// MARK: - UISearchBarDelegate

extension ToDoListTableViewController: UISearchBarDelegate {
    // filter data when you presed search
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        items = items?.filter(containsTitlePredicate, searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: false)
        tableView.reloadData()
    }
    
    // use this method to update(filter) table when you type the text and refresh when delete all of symbols
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
        } else {
            items = items?.filter(containsTitlePredicate, searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: false)
            tableView.reloadData()
        }
    }
    
    // refresh table when you pressed cancel button
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        loadItems()
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
        
    }
}


