
import Foundation
import CoreData
import UIKit

class CoreDataManager{
    static let shared = CoreDataManager()
    private init() {}
    
    var context: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    var notesContext: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).notesPersistentContainer.viewContext
    }
    func addFavourite(recipeId: String, isLocal: Bool) {
        let favouriteRecipe = FavouriteRecipe(context: context)
        favouriteRecipe.id = recipeId
        favouriteRecipe.isLocal = isLocal
        saveContext()
        
        NotificationCenter.default.post(name: .favouritesUpdated, object: nil)
    }
    
    func deleteFavourite(recipeId: String){
        let fetchRequest: NSFetchRequest<FavouriteRecipe> = FavouriteRecipe.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", recipeId)
        do {
            let results = try context.fetch(fetchRequest)
            if let favouriteRecipe = results.first {
                context.delete(favouriteRecipe)
                saveContext()
                NotificationCenter.default.post(name: .favouritesUpdated, object: nil)
            }
        } catch {
            print("Failed to delete favourite recipe: \(error)")
        }
        
    }
    
    func isFavouriteRecipe(id: String) -> Bool {
        let fetchRequest: NSFetchRequest<FavouriteRecipe> = FavouriteRecipe.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        do {
            let results = try context.fetch(fetchRequest)
            if results.first != nil {
                return true
            }else {
                return false
            }
        } catch {
            print("Failed to delete favourite recipe: \(error)")
            return false
        }
    }
    
    func saveContext() {
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    func printAllRecipesFromCoreData() {
        let fetchRequest: NSFetchRequest<FavouriteRecipe> = FavouriteRecipe.fetchRequest()
        do {
            let results = try context.fetch(fetchRequest)
            if results.isEmpty {
                print("No recipes found in Core Data.")
            } else {
                for recipe in results {
                    print("Recipe ID: \(recipe.id ?? "No ID")")
                    print("Is Local: \(recipe.isLocal)")
                    print("-------")
                }
            }
        } catch {
            print("Failed to fetch recipes from Core Data: \(error)")
        }
    }
    func deleteAllRecipesFromCoreData() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "FavouriteRecipe")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            saveContext()
            print("All recipes have been deleted from Core Data.")
        } catch {
            print("Failed to delete all recipes from Core Data: \(error)")
        }
    }
    func fetchAllFavouriteRecipeIDs() -> [String] {
        let fetchRequest: NSFetchRequest<FavouriteRecipe> = FavouriteRecipe.fetchRequest()
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.compactMap { $0.id }
        } catch {
            print("Failed to fetch favourite recipe IDs: \(error)")
            return []
        }
    }
    
    
    //    func printRecipeFromCoreData(id: String){
    //        let fetchRequest: NSFetchRequest<FavouriteRecipe> = FavouriteRecipe.fetchRequest()
    //        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
    //        do {
    //            let results = try context.fetch(fetchRequest)
    //            if let safeResult = results.first  {
    //                print(safeResult)
    //            }else {
    //              print("not found recipe")
    //            }
    //        } catch {
    //            print("Failed to delete favourite recipe: \(error)")
    //        }
    //   }
    //MARK: - Notes
    func fetchAllNotes() -> [Notes] {
        let fetchRequest: NSFetchRequest<Notes> = Notes.fetchRequest()
        do {
            let notes = try notesContext.fetch(fetchRequest)
            return notes
        } catch {
            print("Failed to fetch notes: \(error)")
            return []
        }
    }
    func addNote(title: String, noteText: String, date: Date, idRecipe: String, idNote:String) {
        let note = Notes(context: notesContext)
        note.title = title
        note.note = noteText
        note.noteID = idNote
        note.recipeID = idRecipe
        note.date = date
        
        
        saveNotesContext()
        printAllNotesFromCoreData()
        NotificationCenter.default.post(name: .notesUpdated, object: nil)
    }
    func printAllNotesFromCoreData() {
        let notes = fetchAllNotes()
        if notes.isEmpty {
            print("No notes found in Core Data.")
        } else {
            for note in notes {
                print("Note ID: \(note.noteID ?? "No ID")")
                print("Recipe ID: \(note.recipeID ?? "No Recipe ID")")
                print("Title: \(note.title ?? "No Title")")
                print("Note Text: \(note.note ?? "No Text")")
                print("Date: \(note.date ?? Date())")
                print("-------")
            }
        }
    }
    func fetchNotesForRecipe(idRecipe: String) -> [Notes] {
        let fetchRequest: NSFetchRequest<Notes> = Notes.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "recipeID == %@", idRecipe)
        
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            let notes = try notesContext.fetch(fetchRequest)
            return notes
        } catch {
            print("Failed to fetch notes for recipe ID \(idRecipe): \(error)")
            return []
        }
    }
    func updateNote(noteID: NSManagedObjectID, title: String, noteText: String, date: Date) {
        do {
            if let note = try notesContext.existingObject(with: noteID) as? Notes {
                note.title = title
                note.note = noteText
                note.date = date
                
                saveNotesContext()
                NotificationCenter.default.post(name: .notesUpdated, object: nil)
            }
        } catch {
            print("Failed to update note: \(error)")
        }
    }

    func deleteNoteById(noteId: NSManagedObjectID) {
        do {
            if let note = try notesContext.existingObject(with: noteId) as? Notes {
                notesContext.delete(note)
                saveNotesContext()
                NotificationCenter.default.post(name: .notesUpdated, object: nil)
            }
        } catch {
            print("Failed to delete note: \(error)")
        }
    }
//    func deleteNoteById(noteId: NSManagedObjectID, indexPath: IndexPath) {
//        do {
//            if let note = try notesContext.existingObject(with: noteId) as? Notes {
//                notesContext.delete(note)
//                saveNotesContext()
//                NotificationCenter.default.post(name: .notesUpdated, object: nil)
//                
//                // Удаляем заметку из dataSource
//                dataSource.remove(at: indexPath.row)
//                
//                // Обновляем таблицу
//                tableView.deleteRows(at: [indexPath], with: .automatic)
//            }
//        } catch {
//            print("Failed to delete note: \(error)")
//        }
//    }

    
    func saveNotesContext() {
        (UIApplication.shared.delegate as! AppDelegate).saveNotesContext()
    }
    
}

