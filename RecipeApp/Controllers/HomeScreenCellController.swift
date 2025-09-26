

import UIKit

extension Notification.Name {
    static let startedSwipe = Notification.Name("startedSwipe")
}
class HomeScreenCellController: UITableViewCell {
    
    @IBOutlet weak var meelImage: UIImageView!
    
    @IBOutlet weak var meelName: UILabel!
    
    
    @IBOutlet weak var ingredients: UILabel!
    
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    @IBOutlet weak var toFavButton: UIButton!
    
    @IBOutlet weak var toFavSlideBut: UIButton!
    
    @IBOutlet weak var rightConstraint: NSLayoutConstraint!
    
    var cellID = UUID().uuidString
    
    var isFavorite = false
    var recipe: RecipeModel? {
        
        didSet {
            guard let data = recipe else { return }
            rightConstraint.constant = 15
            meelName.text = data.mealName
            ingredients.text = data.ingredients
            ImageLoader.shared.loadImage(from: data.imageSrc, into: meelImage, with: indicator)
            if CoreDataManager.shared.isFavouriteRecipe(id: data.id) {
                setFavoriteState()
            } else {
                setUnfavoriteState()
            }
        }
        
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        self.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        self.addGestureRecognizer(swipeRight)
        
        NotificationCenter.default.addObserver(self, selector: #selector(favouritesDidUpdate(_:)), name: .favouritesUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(closeSwipes(_:)), name: .startedSwipe, object: nil)
        
    }
    @objc private func closeSwipes(_ notification: Notification){
        guard let userInfo = notification.userInfo, let swipedCellID = userInfo["cellID"] as? String else { return }
        if swipedCellID != self.cellID {
            resetSwipeState()
        }
    }
    private func resetSwipeState() {
        rightConstraint.constant = 15
        toFavSlideBut.isHidden = true
        toFavButton.isHidden = false
        animateCellLayout()
    }
    
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        NotificationCenter.default.post(name: .startedSwipe, object: nil, userInfo: ["cellID": self.cellID])
        toFavSlideBut.isHidden = false
        switch gesture.direction {
        case .left:
            toFavButton.isHidden = true
            rightConstraint.constant = 115
            
        case .right:
            toFavButton.isHidden = false
            rightConstraint.constant = 15
        default:
            break
        }
        animateCellLayout()
    }
    func animateCellLayout(){
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
    
    @IBAction func toFavSlideButTapped(_ sender: UIButton) {
        
        guard let recipeID = recipe?.id else { return }
        let isCurrentlyFavorite = CoreDataManager.shared.isFavouriteRecipe(id: recipeID)
        presentCustomAlert(for: isCurrentlyFavorite ? .remove : .add, recipeID: recipeID)
        
    }
    private func presentCustomAlert(for actionType: AlertActionType, recipeID: String) {
        guard let viewController = parentViewController else { return }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let customAlert = storyboard.instantiateViewController(withIdentifier: "AlertViewController") as? AlertViewController {
            customAlert.delegate = self
            customAlert.actionType = actionType
            customAlert.recipeId = recipeID
            customAlert.loadViewIfNeeded()
            configureAlert(customAlert, for: actionType)
            customAlert.modalPresentationStyle = .overCurrentContext
            viewController.present(customAlert, animated: true)
        }
        
    }
    
    private func configureAlert(_ alert: AlertViewController, for actionType: AlertActionType) {
        switch actionType {
        case .add:
            alert.alertTitle.text = "Add to Favorites?"
            alert.subTitle.text = "Are you sure you want to add this recipe to your favorites?"
            alert.noButton.backgroundColor = .systemRed
            alert.yesButton.backgroundColor = .systemGreen
        case .remove:
            alert.alertTitle.text = "Remove from Favorites?"
            alert.subTitle.text = "Are you sure you want to remove this recipe from your favorites?"
            alert.noButton.backgroundColor = .systemGreen
            alert.yesButton.backgroundColor = .systemRed
        case .cancel:
            break
        default: break
        }
    }
    private var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder?.next
            if let tabBarController = parentResponder as? UITabBarController {
                return tabBarController
            }
        }
        return nil
    }
    private func setFavoriteState() {
        toFavButton.tintColor = .yellow
        toFavButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        rightConstraint.constant = 15
        animateCellLayout()
        toFavSlideBut.setImage(UIImage(systemName: "star.slash"), for: .normal)
        toFavSlideBut.backgroundColor = UIColor(named: "deleteColor")
        toFavSlideBut.isHidden = true
        toFavButton.isHidden = false
    }
    
    private func setUnfavoriteState() {
        toFavButton.tintColor = .gray
        toFavButton.setImage(UIImage(systemName: "star"), for: .normal)
        rightConstraint.constant = 15
        animateCellLayout()
        toFavSlideBut.setImage(UIImage(systemName: "star"), for: .normal)
        toFavSlideBut.backgroundColor = .yellow
        toFavSlideBut.isHidden = true
        toFavButton.isHidden = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .favouritesUpdated, object: nil)
        NotificationCenter.default.removeObserver(self, name: .startedSwipe, object: nil)
    }
    @objc private func favouritesDidUpdate(_ notification: Notification) {
        guard let recipeID = recipe?.id else { return }
        if CoreDataManager.shared.isFavouriteRecipe(id: recipeID) {
            setFavoriteState()
        } else {
            setUnfavoriteState()
        }
    }
}
extension HomeScreenCellController: CustomAlertDelegate {
    func alertAction(_ controller: AlertViewController, didPressButton actionType: AlertActionType, forRecipeId recipeId: String) {
        switch actionType {
        case .add:
            setFavoriteState()
            CoreDataManager.shared.addFavourite(recipeId: recipeId, isLocal: recipe?.isLocal ?? false)
        case .remove:
            setUnfavoriteState()
            CoreDataManager.shared.deleteFavourite(recipeId: recipeId)
        case .cancel:
            resetSwipeState()
        default: print("unknown type")
        }
        
        
        UIView.animate(withDuration: 0.5) {
            controller.view.backgroundColor = .clear
        } completion: { finish in
            controller.dismiss(animated: true)
        }

    }
}
