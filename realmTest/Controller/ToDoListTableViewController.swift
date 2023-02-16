//
//  ToDoListTableViewController.swift
//  realmTest
//
//  Created by Марк Голубев on 13.02.2023.
//

import UIKit
import RealmSwift

class ToDoListTableViewController: UITableViewController {
    
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
        
        // created controller
        let ac = UIAlertController(title: "Add Item to your to do list", message: nil, preferredStyle: .alert)
        // added TextField
        ac.addTextField()
        ac.textFields?[0].placeholder = "Create new Item"
        
        
        // created action button
        let addAction = UIAlertAction(title: "Add Item", style: .default) {
            // trying to avoid strong reference
            [weak self, weak ac] action in
            // checked textField is not nil
            guard let item = ac?.textFields?[0].text, item != "" else { return }
            // use button Submit using answer and method out of closure
            self?.submit(item)
        }
        
        ac.addAction(addAction)
        present(ac, animated: true)
    }
    
    //     added submit function for action controller
    func submit(_ item: String) {
        
        let newItem = Item()
        newItem.title = item
        save(item: newItem)
        
        // update one row
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.insertRows(at: [indexPath], with: .automatic)
        return
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
    
    //        func deleteData(with indexPath: IndexPath) {
    //
    //            context.delete(items[indexPath.row])
    //            items.remove(at: indexPath.row)
    //
    //
    //        }
    
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.image = UIImage(systemName: "applelogo")
        if let item = items?[indexPath.row] {
            content.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
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
    
    // add delete cell functional
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let item = items?[indexPath.row] {
                do {
                    try realm.write({
                        realm.delete(item)
                    })
                } catch {
                    print("error updating done status \(error.localizedDescription)")
                }
            }
            tableView.deleteRows(at: [indexPath], with: .bottom)
        }
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


