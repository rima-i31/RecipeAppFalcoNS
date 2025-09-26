

import UIKit

class NotesViewController: UIViewController {
    var k = K()
    var notesTableVC = NotesTableViewController()
    var notes:[Notes] = []
    var addButton: UIBarButtonItem?
    var idRecipe: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(notesDidUpdate), name: .notesUpdated, object: nil)
        addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        navigationItem.rightBarButtonItem = addButton
        
        if let recipeId = idRecipe{
            notes = CoreDataManager.shared.fetchNotesForRecipe(idRecipe: recipeId)
        }else{
            print("not found recipe")
        }
        notesTableVC.dataSource = notes
        addChild(notesTableVC)
        view.addSubview(notesTableVC.view)
        notesTableVC.didMove(toParent: self)
        notesTableVC.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
        
        
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: .favouritesUpdated, object: nil)
    }
    @objc func notesDidUpdate(){
        if let recipeId = idRecipe {
            notes = CoreDataManager.shared.fetchNotesForRecipe(idRecipe: recipeId)
        }
        notesTableVC.dataSource = notes
        notesTableVC.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
    }
    @objc func addButtonTapped() {
        performSegue(withIdentifier: k.segueToAddNote, sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == k.segueToAddNote {
            if let addNoteVC = segue.destination as? AddNoteViewController {
                addNoteVC.idRecipe = self.idRecipe
            }
        }
    }
}
