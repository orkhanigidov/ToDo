//
//  ToDoViewController.swift
//  ToDo
//
//  Created by Orxan Igidov on 6/18/20.
//  Copyright © 2020 Orxan Igidov. All rights reserved.
//

import UIKit
import CoreData

class ToDoViewController: UITableViewController {
    
    // MARK: - ToDoViewController properties
    
    var listArray = [List]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // MARK: - ToDoViewController methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.separatorStyle = .none
        self.tableView.rowHeight = 50
        loadContext()
    }
    
    // MARK: - ToDoViewController IBActions
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        var title = UITextField()
        
        let alert = UIAlertController(title: "Add New List", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add List", style: .default) { (action) in
            let newList = List(context: self.context)
            newList.title = title.text
            self.listArray.append(newList)
            self.saveContext()
        }
        alert.addTextField { (textField) in
            title = textField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDataSource methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListsCell", for: indexPath)
        cell.textLabel?.text = listArray[indexPath.row].title
        return cell
    }
    
    // MARK: - UITableViewDelegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToTasks", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let list = listArray[indexPath.row]
            context.delete(list)
            listArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            saveContext()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        if let destination = segue.destination as? TasksViewController {
            destination.selectedList = listArray[indexPath.row]
        }
    }
    
    // MARK: - Core Data methods
    
    func saveContext() {
        do {
            try context.save()
        } catch let error {
            print(error.localizedDescription)
        }
        tableView.reloadData()
    }
    
    func loadContext() {
        let request: NSFetchRequest<List> = List.fetchRequest()
        do {
            listArray = try context.fetch(request)
        } catch let error {
            print(error.localizedDescription)
        }
        tableView.reloadData()
    }
}
