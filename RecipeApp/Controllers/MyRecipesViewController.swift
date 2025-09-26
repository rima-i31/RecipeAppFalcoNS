

import UIKit

class MyRecipesViewController: UIViewController {
    
    var k = K()
    var userRecipes: [RecipeModel] = []
    var user = UserData()
    var recipesTableVC = RecipesTableViewController()
    var addRecipeVC = AddRecipeViewController()
    var addButton: UIBarButtonItem?
    override func viewDidLoad() {
        super.viewDidLoad()
        addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        navigationItem.rightBarButtonItem = addButton
        let appearance = UINavigationBarAppearance()
        
        appearance.backgroundColor = .white
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        self.title = "My Recipes"
        NotificationCenter.default.addObserver(self, selector: #selector(recipesDidUpdate), name: .userRecipesUpdated, object: nil)
        
        loadUserRecipes()
        
        recipesTableVC.dataSource = userRecipes.reversed()
        addChild(recipesTableVC)
        view.addSubview(recipesTableVC.view)
        recipesTableVC.didMove(toParent: self)
        recipesTableVC.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
        
        recipesTableVC.tableView.reloadData()
    }
    @objc func addButtonTapped() {
        performSegue(withIdentifier: k.segueToAddMenu, sender: self)
    }
    @objc func recipesDidUpdate() {
        loadUserRecipes()
        recipesTableVC.tableView.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .userRecipesUpdated, object: nil)
    }
    
    func loadUserRecipes() {
        if let userData = UserData.loadFromDefaults(), let recipes = userData.userRecipes {
            userRecipes = recipes
            recipesTableVC.dataSource = userRecipes.reversed()
            recipesTableVC.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
        }
    }
    
}
