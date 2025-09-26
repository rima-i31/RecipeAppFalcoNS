

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var recipeImage: UIImageView!
    
    @IBOutlet weak var ingredientsLabel: UILabel!
    
    @IBOutlet weak var instructionsLabel: UILabel!
    
    @IBOutlet weak var detailStackView: UIStackView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var scrollContainerView: UIView!
    
    
    
    var imageSrc: String?
    var mealName: String?
    var measuredIngredients: String?
    var instructions: String?
    var idRecipe: String?
    var k = K()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 3.0
        
        if let imageSrc = imageSrc {
            ImageLoader.shared.loadImage(from: imageSrc, into: recipeImage, with: nil)
        }
        
        
        ingredientsLabel.text = measuredIngredients
        instructionsLabel.text = instructions
        self.navigationItem.title = mealName
        
        let rightBarButton = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(rightBarButtonTapped))
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        recipeImage.contentMode = .scaleAspectFill
        scrollContainerView.layer.shadowColor = UIColor.black.cgColor
        scrollContainerView.layer.shadowOpacity = 0.5
        scrollContainerView.layer.shadowOffset = CGSize(width: 5, height: 5)
        scrollContainerView.clipsToBounds = false
        scrollView.layer.cornerRadius = 16
        scrollContainerView.layer.cornerRadius = 16
        recipeImage.layer.cornerRadius = 16
        scrollView.clipsToBounds = true
        recipeImage.clipsToBounds = true
        
    }
    @objc func rightBarButtonTapped() {
        
        let textToShare = "\(mealName ?? "") \n \n \(measuredIngredients ?? "") \n \(instructions ?? "") "
        
        let activityController = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == k.segueToNotes {
                if let notesVC = segue.destination as? NotesViewController {
                    notesVC.idRecipe = self.idRecipe
                }
            }
        }
}

extension DetailViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return recipeImage
    }
}
