

import UIKit

class AddRecipeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddCellTableViewCellDelegate {
    
    @IBOutlet weak var addRecipeTable: UITableView!
    
    var k = K()
    var imagePath: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addRecipeTable.delegate = self
        addRecipeTable.dataSource = self
        addRecipeTable.register(UINib(nibName: k.addRecipeCell, bundle: nil), forCellReuseIdentifier: k.addRecipeCell)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: self.k.addRecipeCell, for: indexPath) as? AddCellTableViewCell {
            cell.delegate = self
            return cell
        }else{
            return UITableViewCell()
        }
    }
    func didCreateRecipe() {
        self.navigationController?.popViewController(animated: true)
    }
}

