

import UIKit
protocol AddCellTableViewCellDelegate: AnyObject {
    func didCreateRecipe()
}

class AddCellTableViewCell: UITableViewCell, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate{
    var delegate: AddCellTableViewCellDelegate?
    @IBOutlet weak var recipeNameLabel: UILabel!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var ingredientsLabel: UILabel!
    
    @IBOutlet weak var ingredientsTextView: UITextView!
    
    @IBOutlet weak var instructionsLabel: UILabel!
    
    @IBOutlet weak var instructionsTextView: UITextView!
    
    @IBOutlet weak var addImageButton: UIButton!
    
    
    @IBOutlet weak var recipeImage: UIImageView!
    
    
    var selectedImage: UIImage?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameTextField.delegate = self
        ingredientsTextView.delegate = self
        instructionsTextView.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.contentView.addGestureRecognizer(tapGesture)
    }
    @objc func dismissKeyboard() {
        self.endEditing(true)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        guard let recipeName = nameTextField.text, !recipeName.isEmpty,
              let ingredientsText = ingredientsTextView.text, !ingredientsText.isEmpty,
              let instructions = instructionsTextView.text, !instructions.isEmpty else {
            showAlert(message: "All fields are required")
            return
        }
        
        
        let ingredientsArray = ingredientsText.components(separatedBy: "\n").compactMap { $0 }
        
        let ingredientsOnlyArray = ingredientsArray.map { ingredient in
            return ingredient.components(separatedBy: ":").first?.trimmingCharacters(in: .whitespaces) ?? ""
        }
        let ingredientsString = ingredientsOnlyArray.joined(separator: ", ")
        
        let measuredIngredientsStr = ingredientsArray.joined(separator: "\n")
        
        var imagePath = ""
        if let image = selectedImage {
            imagePath = saveImageToDocuments(image: image)
        }else{
            imagePath = saveImageToDocuments(image: UIImage(named: "imagePlaceholder")!)
        }
        
        let newRecipe = RecipeModel(
            imageSrc: imagePath,
            mealName: recipeName,
            ingredients: ingredientsString,
            id: UUID().uuidString,
            measuredIngredients: measuredIngredientsStr,
            instructions: instructions,
            isLocal: true
        )
        
        
        var currentUserData = UserData.loadFromDefaults() ?? UserData()
        
        
        if currentUserData.userRecipes == nil {
            currentUserData.userRecipes = [newRecipe]
        } else {
            currentUserData.userRecipes?.append(newRecipe)
        }
        
        currentUserData.saveToDefaults()
        
        print("Новый рецепт создан: \(newRecipe)")
        self.delegate?.didCreateRecipe()
        NotificationCenter.default.post(name: .userRecipesUpdated, object: nil)
    }
    
    @IBAction func addImageTapped(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        if let viewController = self.window?.rootViewController {
            viewController.present(imagePicker, animated: true, completion: nil)
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
        }
        
        if let selectedImage = selectedImage {
            recipeImage.image = selectedImage
            recipeImage.backgroundColor = .clear
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        if let viewController = self.window?.rootViewController {
            viewController.present(alert, animated: true, completion: nil)
        }
    }
    
    func saveImageToDocuments(image: UIImage) -> String {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let imageName = UUID().uuidString + ".png"
        let imageURL = documentDirectory.appendingPathComponent(imageName)
        
        if let imageData = image.pngData() {
            do {
                try imageData.write(to: imageURL)
                print("Image saved successfully at \(imageURL)")
            } catch {
                print("Error saving image: \(error)")
            }
        }
        
        return imageURL.path
    }
    
}
