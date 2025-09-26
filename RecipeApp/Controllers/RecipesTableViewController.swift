

import UIKit

class RecipesTableViewController: UITableViewController {
    func didAddRecipe() {
        loadUserRecipes()
    }
    func loadUserRecipes() {
        if let userData = UserData.loadFromDefaults(), let recipes = userData.userRecipes {
            userRecipes = recipes
            tableView.reloadSections(self.k.indexSet, with: .fade)
        }
    }
    
    var userRecipes: [RecipeModel] = []
    var isLoading: Bool = false
    
    var k = K()
    var toDetails = ToDetailsSegueManager()
    var dataSource: [RecipeModel] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: k.idCell, bundle: nil), forCellReuseIdentifier: k.idCell)
        tableView.register(UINib(nibName: k.idErrorCell, bundle: nil), forCellReuseIdentifier: k.idErrorCell)
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        tableView.separatorInset = tableView.layoutMargins
        
    }
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isLoading {
            return 0
        }
        return dataSource.isEmpty ? 1 : dataSource.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if dataSource.isEmpty {
            let errorCell = tableView.dequeueReusableCell(withIdentifier: k.idErrorCell, for: indexPath) as! NoRecipeTableViewCell
            return errorCell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: k.idCell, for: indexPath) as! HomeScreenCellController
            let recipe = dataSource[indexPath.row]
            cell.recipe = recipe
            return cell
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let detailVC = storyboard.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
            let selectedRecipe = dataSource[indexPath.row]
            toDetails.trnsferData(from: selectedRecipe, to: detailVC)
            navigationController?.pushViewController(detailVC, animated: true)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == k.segueToDetails {
            if let destinationVC = segue.destination as? DetailViewController, let indexPath = tableView.indexPathForSelectedRow {
                
                toDetails.trnsferData(from: dataSource[indexPath.row], to: destinationVC)
            }
        }
    }
    func updateData(_ recipes: [RecipeModel]) {
        dataSource = recipes
        tableView.reloadData()
    }
    
}
