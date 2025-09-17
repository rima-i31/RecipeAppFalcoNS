//
//  HomeScreenViewController.swift
//  intershipApp
//
//  Created by Rima Mihova on 05.08.2024.
//

import UIKit

class HomeScreenViewController: UIViewController {
    
    
    @IBOutlet weak var homeTableView: UITableView!
    
    
    var loadingIndicator = UIActivityIndicatorView(style: .large)
    
    
    var recipeManager = RecipeManager()
    var recipes: [RecipeModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Recipes"
        
        self.navigationItem.hidesBackButton = true
        
        homeTableView.delegate = self
        homeTableView.dataSource = self
        homeTableView.register(UINib(nibName: "HomeScreenCell", bundle: nil), forCellReuseIdentifier: "HomeScreenCell")
        
        setupLoadingIndicator()
        recipeManager.delegate = self
        loadingIndicator.startAnimating()
        loadRandomRecipes()
    }
    func loadRandomRecipes() {
        for _ in 1...20 {
            recipeManager.getRecipes()
        }
    }
    func setupLoadingIndicator() {
        loadingIndicator.center = view.center
        loadingIndicator.hidesWhenStopped = true
        view.addSubview(loadingIndicator)
    }
    
}
//MARK: - UITableViewDelegate
extension HomeScreenViewController: UITableViewDelegate{
}
//MARK: - UITableViewDataSource
extension HomeScreenViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HomeScreenCell", for: indexPath) as? HomeScreenCellController else {
            return UITableViewCell()
        }
        let recipe = recipes[indexPath.row]
        cell.meelName.text = recipe.mealName
        cell.ingredients.text = recipe.ingredients
        
        //           cell.meelImage.image = UIImage(data: try! Data(contentsOf: URL(string: recipe.imageSrc)!))
        if let imageUrl = URL(string: recipe.imageSrc) {
            URLSession.shared.dataTask(with: imageUrl) { data, response, error in
                if let data = data, error == nil {
                    DispatchQueue.main.async {
                        cell.meelImage.image = UIImage(data: data)
                    }
                }
            }.resume()
        }
        
        return cell
    }
}

//MARK: - RecipeManagerDelegate
extension HomeScreenViewController: RecipeManagerDelegate{
    func didUpdateRecipe(newRecipe: RecipeModel) {
        DispatchQueue.main.async {
            self.recipes.append(newRecipe)
            if self.recipes.count == 20 {
                self.loadingIndicator.stopAnimating()
                self.homeTableView.reloadData()
            }
            
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
        DispatchQueue.main.async {
            self.loadingIndicator.stopAnimating()
        }
    }
    
}
