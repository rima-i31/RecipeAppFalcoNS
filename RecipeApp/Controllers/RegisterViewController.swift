

import UIKit

class RegisterViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    
    let nameCell = CellData(cellName: "First Name")
    let lastNameCell = CellData(cellName: "Last Name")
    let phoneCell = CellData(cellName: "Phone number")
    let birthdayCell = CellData(cellName: "Birthday")
    let passwordCell = CellData(cellName: "Password")
    let passswordVerificationCell = CellData(cellName: "Repeat password")
    var cellsArray:[CellData] = []
    var user = UserData()
    var k = K()
    override func viewDidLoad() {
        super.viewDidLoad()
        if let loadedUser = UserData.loadFromDefaults() {
            user = loadedUser
        }
        cellsArray = [nameCell, lastNameCell, phoneCell, birthdayCell, passwordCell, passswordVerificationCell]
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: k.idRegistrationCell, bundle: nil), forCellReuseIdentifier: k.idRegistrationCell)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        guard let firstName = user.firstName, !firstName.isEmpty,
              let lastName = user.lastName, !lastName.isEmpty,
              let phoneNumber = user.phoneNumber, !phoneNumber.isEmpty,
              let birthDay = user.birthDay, !birthDay.isEmpty,
              let password = user.password, !password.isEmpty,
              let passwordVerification = user.passwordVerification, !passwordVerification.isEmpty else {
            showAlert(message: "Please fill in all fields.")
            return
        }
        
        guard password == passwordVerification else {
            showAlert(message: "Passwords do not match.")
            return
        }
        
        user.id = UUID().uuidString
        user.saveToDefaults()
        print(user)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController {
            if let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate {
                sceneDelegate.window?.rootViewController = tabBarController
            }
        }
        
    }
    
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}
extension RegisterViewController: UITableViewDelegate{
}
//MARK: - UITextFieldDelegate
extension RegisterViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        let index = textField.tag
        
        switch index{
        case 0: user.firstName = textField.text
        case 1: user.lastName = textField.text
        case 2: user.phoneNumber = textField.text
        case 3: user.birthDay = textField.text
        case 4: user.password = textField.text
        case 5: user.passwordVerification = textField.text
        default: print("unknown textfield")
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        if let nextResponder = tableView.viewWithTag(nextTag) as? UITextField {
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        switch textField.tag {
        case 2:
            textField.text = format(phoneNumber: prospectiveText)
            return false
        case 3:
            textField.text = format(birthday: prospectiveText)
            return false
        default:
            return true
        }
    }
    private func format(phoneNumber: String) -> String {
        let numbers = phoneNumber.replacingOccurrences(of: "\\D", with: "", options: .regularExpression)
        let formatted = numbers.prefix(11).enumerated().map { (index, char) -> String in
            switch index {
            case 0: return "(\(char)"
            case 2: return "\(char)) "
            case 5,8: return "-\(char)"
            default: return String(char)
            }
        }.joined()
        return formatted
    }
    private func format(birthday: String) -> String {
        let numbers = birthday.replacingOccurrences(of: "\\D", with: "", options: .regularExpression)
        let formatted = numbers.prefix(8).enumerated().map { (index, char) -> String in
            switch index {
            case 2, 4: return "/\(char)"
            default: return String(char)
            }
        }.joined()
        return formatted
    }
    
    
}
//MARK: - UITableViewDataSource
extension RegisterViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: k.idRegistrationCell, for: indexPath) as? RegistrationViewCell else {
            return UITableViewCell()
        }
        cell.cellLabel.text = cellsArray[indexPath.row].cellName
        cell.textField.tag = indexPath.row
        cell.textField.delegate = self
        
        switch indexPath.row {
        case 4, 5:
            cell.textField.isSecureTextEntry = true
            cell.textField.textContentType = .oneTimeCode
        default:
            break
        }
        
        return cell
    }
    
}
