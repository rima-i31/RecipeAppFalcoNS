

import Foundation
protocol RecipeManagerDelegate{
    func didUpdateRecipe(newRecipe:RecipeModel)
    func didFailWithError(error:Error)
}


struct RecipeManager{
    var k = K()
    var delegate:RecipeManagerDelegate?
    var mainURL: String {
            return k.getRecipeUrl
        }
    func getRecipes(){
        let urlString = mainURL
        performRequest(with:urlString)
    }
    func performRequest(with urlString:String){
        if let url = URL(string: urlString){
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil{
                    delegate?.didFailWithError(error: error!)
                    print(error!)
                    return
                }
                if let safeData = data{
                    if let recipe =  parseJSON(safeData){
                        
                        delegate?.didUpdateRecipe(newRecipe: recipe)
                    }
                    
                }
            }
            task.resume()
        }
        
    }
    func parseJSON(_ data:Data)->RecipeModel?{
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(RecipeData.self, from: data)
            print(decodedData.meals[0].strMeal)
            let receivedMeal = decodedData.meals[0]
            let idMeel = receivedMeal.idMeal
            let name = receivedMeal.strMeal
            let instructionsStr = receivedMeal.strInstructions
            let ingredients = [receivedMeal.strIngredient1, receivedMeal.strIngredient2,receivedMeal.strIngredient3,receivedMeal.strIngredient4,receivedMeal.strIngredient5,receivedMeal.strIngredient6,receivedMeal.strIngredient7,receivedMeal.strIngredient8,receivedMeal.strIngredient9,receivedMeal.strIngredient10,receivedMeal.strIngredient11,receivedMeal.strIngredient12,receivedMeal.strIngredient13,receivedMeal.strIngredient14,receivedMeal.strIngredient15,receivedMeal.strIngredient16,receivedMeal.strIngredient17,receivedMeal.strIngredient18,receivedMeal.strIngredient19,receivedMeal.strIngredient20]
            let ingredientsString = ingredients.compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: ", ")
            let measures = [receivedMeal.strMeasure1,receivedMeal.strMeasure2,receivedMeal.strMeasure3,receivedMeal.strMeasure4,receivedMeal.strMeasure5,receivedMeal.strMeasure6,receivedMeal.strMeasure7,receivedMeal.strMeasure8,receivedMeal.strMeasure9,receivedMeal.strMeasure10,receivedMeal.strMeasure11,receivedMeal.strMeasure12,receivedMeal.strMeasure13,receivedMeal.strMeasure14,receivedMeal.strMeasure15,receivedMeal.strMeasure16,receivedMeal.strMeasure17,receivedMeal.strMeasure18,receivedMeal.strMeasure19,receivedMeal.strMeasure20]
            
            var measuredIngredientsStr = ""
                   for (index, ingredient) in ingredients.enumerated() {
                       if let ingredient = ingredient, !ingredient.isEmpty {
                           let measure = measures[index] ?? ""
                           if !measure.isEmpty {
                               measuredIngredientsStr += "\(ingredient):  \(measure)\n"
                           } else {
                               measuredIngredientsStr += "\(ingredient)\n"
                           }
                       }
                   }
            
            
            let imageSrc = decodedData.meals[0].strMealThumb
            let recipe = RecipeModel(imageSrc: imageSrc, mealName: name, ingredients: ingredientsString, id: idMeel, measuredIngredients: measuredIngredientsStr, instructions: instructionsStr, isLocal: false)
            return recipe
        } catch{
            delegate?.didFailWithError(error: error)
            print(error)
            return nil
        }
    }
}


