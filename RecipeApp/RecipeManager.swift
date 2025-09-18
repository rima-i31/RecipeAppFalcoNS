

import Foundation
protocol RecipeManagerDelegate{
    func didUpdateRecipe(newRecipe:RecipeModel)
    func didFailWithError(error:Error)
}


struct RecipeManager{
    var delegate:RecipeManagerDelegate?
    let mainURL = "https://www.themealdb.com/api/json/v1/1/random.php"
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
            let name = receivedMeal.strMeal
            let ingredients = [receivedMeal.strIngredient1, receivedMeal.strIngredient2,receivedMeal.strIngredient3,receivedMeal.strIngredient4,receivedMeal.strIngredient5,receivedMeal.strIngredient6,receivedMeal.strIngredient7,receivedMeal.strIngredient8,receivedMeal.strIngredient9,receivedMeal.strIngredient10,receivedMeal.strIngredient11,receivedMeal.strIngredient12,receivedMeal.strIngredient13,receivedMeal.strIngredient14,receivedMeal.strIngredient15,receivedMeal.strIngredient16,receivedMeal.strIngredient17,receivedMeal.strIngredient18,receivedMeal.strIngredient19,receivedMeal.strIngredient20]
            let ingredientsString = ingredients.compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: ", ")
            let imageSrc = decodedData.meals[0].strMealThumb
            let recipe = RecipeModel(imageSrc: imageSrc, mealName: name, ingredients: ingredientsString)
            return recipe
        } catch{
            delegate?.didFailWithError(error: error)
            print(error)
            return nil
        }
    }
}


