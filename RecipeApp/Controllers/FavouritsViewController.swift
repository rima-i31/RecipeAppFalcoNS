

import UIKit

class FavouritsViewController: UIViewController {
    
    
    var k = K()
    var user = UserData()
    var recipes: [RecipeModel] = []
    var userRecipes: [RecipeModel] = []
    var favourits: [RecipeModel] = []
    var recipesTableVC = RecipesTableViewController()
    var toggleFav: UIBarButtonItem?
    var isShowingUserRecipes : Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .white
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        self.title = "Favorites"
        toggleFav = UIBarButtonItem(title: "My Recipes", style: .plain, target: self, action: #selector(toggleFavButtonTapped))
        self.navigationItem.rightBarButtonItem = toggleFav
        
        getFavourits()
        recipesTableVC.dataSource = favourits
        
        
        
        //
        //        //recipesTableVC.updateData(foundRecipes)
        //        //addChild(recipesTableVC)
        //        //view.addSubview(recipesTableVC.view)
        //        //recipesTableVC.didMove(toParent: self)
        //        recipesTableVC.view.translatesAutoresizingMaskIntoConstraints = false
        //        NSLayoutConstraint.activate([
        //            recipesTableVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        //            recipesTableVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        //            recipesTableVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        //            recipesTableVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        //        ])
        addChild(recipesTableVC)
        view.addSubview(recipesTableVC.view)
        recipesTableVC.didMove(toParent: self)
        recipesTableVC.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
        NotificationCenter.default.addObserver(self, selector: #selector(favouritesDidUpdate), name: .favouritesUpdated, object: nil)
    }
    @objc func favouritesDidUpdate() {
        getFavourits()
        recipesTableVC.dataSource = favourits
        recipesTableVC.tableView.reloadData()
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: .favouritesUpdated, object: nil)
    }
    func getFavourits (){
        if let savedRecipes = user.loadRecipesFromUserDefaults() {
            recipes = savedRecipes
        }
        if let userData = UserData.loadFromDefaults(), let recipes = userData.userRecipes {
            userRecipes = recipes
        }
        let favouriteIDs = CoreDataManager.shared.fetchAllFavouriteRecipeIDs()
        let currentRecipes = isShowingUserRecipes ? userRecipes : recipes
        favourits = currentRecipes.filter { favouriteIDs.contains($0.id) }
        recipesTableVC.dataSource = favourits
        recipesTableVC.tableView.reloadData()
    }
    
    @objc func toggleFavButtonTapped() {
        isShowingUserRecipes.toggle()
        updateToggleButtonTitle()
        getFavourits()
    }
    
    func updateToggleButtonTitle() {
        toggleFav?.title = isShowingUserRecipes ? "All Recipes" : "My Recipes"
    }
}
