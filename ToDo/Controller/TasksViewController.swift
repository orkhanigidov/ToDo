//
//  TasksViewController.swift
//  ToDo
//
//  Created by Orxan Igidov on 6/18/20.
//  Copyright © 2020 Orxan Igidov. All rights reserved.
//

import UIKit
import CoreData

class TasksViewController: UITableViewController {

    // MARK: - TasksViewController properties
    
    var selectedList: List? {
        didSet {
            loadContext()
        }
    }
    var tasksArray = [Task]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // MARK: - TasksViewController methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = selectedList?.title
        self.tableView.separatorStyle = .none
        self.tableView.rowHeight = 50
    }

    // MARK: - TasksViewController IBActions
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        var title = UITextField()
        
        let alert = UIAlertController(title: "Add New Task", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Task", style: .default) { (action) in
            let newTask = Task(context: self.context)
            newTask.title = title.text
            newTask.list = self.selectedList
            self.tasksArray.append(newTask)
            self.saveContext()
        }
        alert.addTextField { (textField) in
            title = textField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        tableView.isEditing = !tableView.isEditing
        sender.title = sender.title == "Edit" ? "Done" : "Edit"
    }
    
    // MARK: - UITableViewDataSource methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasksArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TasksCell", for: indexPath)
        let task = tasksArray[indexPath.row]
        cell.textLabel?.text = task.title
        cell.accessoryType = task.done == true ? .checkmark : .none
        return cell
    }
    
    // MARK: - UITableViewDelegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tasksArray[indexPath.row].done = !tasksArray[indexPath.row].done
        saveContext()
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = tasksArray[indexPath.row]
            context.delete(task)
            tasksArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            saveContext()
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let task = tasksArray[sourceIndexPath.row]
        tasksArray.remove(at: sourceIndexPath.row)
        tasksArray.insert(task, at: destinationIndexPath.row)
    }
    
    func colorForIndex(index: Int) -> UIColor {
        let taskCount = tasksArray.count - 1
        let colorValue = (CGFloat(index) / CGFloat(taskCount)) * 0.6
        return UIColor(red: 1.0, green: colorValue, blue: 0.0, alpha: 1.0)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = colorForIndex(index: indexPath.row)
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
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        guard let title = selectedList?.title else { return }
        let listPredicate = NSPredicate(format: "list.title MATCHES %@", title)
        request.predicate = listPredicate
        do {
            tasksArray = try context.fetch(request)
        } catch let error {
            print(error.localizedDescription)
        }
        tableView.reloadData()
    }
}
