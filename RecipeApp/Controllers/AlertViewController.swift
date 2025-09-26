
import UIKit

protocol CustomAlertDelegate: AnyObject {
    func alertAction(_ controller: AlertViewController, didPressButton actionType: AlertActionType, forRecipeId recipeId: String)
}
enum AlertActionType {
    case add
    case remove
    case cancel
    case unknown
}

class AlertViewController: UIViewController {
    
    @IBOutlet weak var alertTitle: UILabel!
    
    @IBOutlet weak var subTitle: UILabel!
    
    @IBOutlet weak var noButton: UIButton!
    
    @IBOutlet weak var yesButton: UIButton!
    
    weak var delegate: CustomAlertDelegate?
    var actionType: AlertActionType?
    var recipeId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        if let alertView = self.view.subviews.first {
            alertView.layer.cornerRadius = 10
            alertView.layer.masksToBounds = true
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.25) {
            self.view.backgroundColor = UIColor(red: 61.0/255.0, green: 73.0/255.0, blue: 101.0/255.0, alpha: 0.7)
        }
    }
    
    
    @IBAction func noButtonTapped(_ sender: UIButton) {
        guard let recipeId = recipeId else { return }
        delegate?.alertAction(self, didPressButton: .cancel, forRecipeId: recipeId)
    }
    
    @IBAction func yesButtonTapped(_ sender: UIButton) {
        guard let actionType = actionType, let recipeId = recipeId else { return }
        delegate?.alertAction(self, didPressButton: actionType, forRecipeId: recipeId)
    }
}
