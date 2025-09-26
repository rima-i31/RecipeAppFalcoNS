//
//  RecipeModel.swift
//  intershipApp
//
//  Created by Rima Mihova on 05.08.2024.
//

import Foundation

struct RecipeModel: Codable{
    let imageSrc:String
    let mealName: String
    let ingredients:String
    let id: String
    let measuredIngredients: String
    let instructions: String
    let isLocal: Bool
}
