
import UIKit

class NotesTableViewController: UITableViewController {
    var k = K()
    var dataSource: [Notes] = [] {
        didSet {
            tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(notesDidUpdate), name: .notesUpdated, object: nil)
        tableView.register(UINib(nibName: "NoNotesCell", bundle: nil), forCellReuseIdentifier: "NoNotesCell")
        tableView.register(UINib(nibName: "NotesTableViewCell", bundle: nil), forCellReuseIdentifier: "NotesTableViewCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70.0
        updateSeparatorStyle()
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .favouritesUpdated, object: nil)
    }
    private func updateSeparatorStyle() {
        if dataSource.isEmpty {
            tableView.separatorStyle = .none
        } else {
            tableView.separatorStyle = .singleLine
        }
    }
    @objc func notesDidUpdate(){
        updateSeparatorStyle()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let addNoteVC = storyboard.instantiateViewController(withIdentifier: "AddNoteViewController") as? AddNoteViewController{
            let selectedNote = dataSource[indexPath.row]
            addNoteVC.noteToEdit = selectedNote
            addNoteVC.idRecipe = selectedNote.recipeID
            navigationController?.pushViewController(addNoteVC, animated: true)
        }
        
        
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dataSource.count>0 {
            return dataSource.count
            
        } else{
            return 1
        }
        
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if dataSource.count>0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NotesTableViewCell", for: indexPath) as! NotesTableViewCell
            let note = dataSource[indexPath.row]
            cell.note = note
            return cell
        } else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoNotesCell", for: indexPath) as! NoNoteTableViewCell
            return cell
        }
        
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let noteToDelete = dataSource[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            
            CoreDataManager.shared.deleteNoteById(noteId: noteToDelete.objectID)
            self.updateSeparatorStyle()
            completionHandler(true)
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
}
