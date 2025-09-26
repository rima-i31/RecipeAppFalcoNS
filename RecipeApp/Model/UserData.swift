

import Foundation
extension Notification.Name {
    static let recipesUpdated = Notification.Name("recipesUpdated")
}


struct UserData: Codable{
    var firstName: String?
    var lastName: String?
    var birthDay: String?
    var phoneNumber: String?
    var password: String?
    var passwordVerification: String?
    var id: String?
    var userRecipes: [RecipeModel]?

    
    func saveToDefaults() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: "UserData")
        }
    }
    
    static func loadFromDefaults() -> UserData? {
        if let savedUserData = UserDefaults.standard.object(forKey: "UserData") as? Data {
            if let loadedUserData = try? JSONDecoder().decode(UserData.self, from: savedUserData) {
                return loadedUserData
            }
        }
        return nil
    }
    func saveRecipesToUserDefaults(_ recipes: [RecipeModel]) {
        if let encoded = try? JSONEncoder().encode(recipes) {
            UserDefaults.standard.set(encoded, forKey: "SavedRecipes")
        }
      
    }
    func loadRecipesFromUserDefaults() -> [RecipeModel]? {
        if let savedRecipesData = UserDefaults.standard.object(forKey: "SavedRecipes") as? Data {
            if let savedRecipes = try? JSONDecoder().decode([RecipeModel].self, from: savedRecipesData) {
                return savedRecipes
            }
        }
        return nil
    }
}

