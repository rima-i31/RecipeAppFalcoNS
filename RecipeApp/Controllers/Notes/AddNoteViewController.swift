
import UIKit

class AddNoteViewController: UIViewController, UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var noteTextView: UITextView!
    
    var idRecipe: String?
    var noteToEdit: Notes?
    private var isNoteSaved = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Кнопка Done
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        
        // Настройка UITextView
        noteTextView.delegate = self
        noteTextView.font = UIFont.systemFont(ofSize: 20)
        noteTextView.textColor = .white
        noteTextView.isEditable = true
        
        // Загрузка существующей заметки
        if let note = noteToEdit {
            noteTextView.attributedText = attributedTextWithExistingNote(note)
        }
        
        // Добавление кнопки вставки фото
        let addPhotoButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(addPhotoTapped))
        navigationItem.leftBarButtonItem = addPhotoButton
        
        // Тап для скрытия клавиатуры
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        // Подписка на появление и скрытие клавиатуры
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Клавиатура
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardHeight = keyboardFrame.height
        noteTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight + 10, right: 0)
        noteTextView.scrollIndicatorInsets = noteTextView.contentInset
        noteTextView.scrollRangeToVisible(noteTextView.selectedRange)
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        noteTextView.contentInset = .zero
        noteTextView.scrollIndicatorInsets = .zero
    }
    
    // MARK: - Вставка фото
    @objc func addPhotoTapped() {
        let alert = UIAlertController(title: "Добавить фото", message: nil, preferredStyle: .actionSheet)
        
        // Камера
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Сделать фото", style: .default, handler: { _ in
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.sourceType = .camera
                self.present(picker, animated: true)
            }))
        }
        
        // Галерея
        alert.addAction(UIAlertAction(title: "Выбрать из галереи", style: .default, handler: { _ in
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            self.present(picker, animated: true)
        }))
        
        // Отмена
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        
        present(alert, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let selectedImage = info[.originalImage] as? UIImage {
            let attachment = NSTextAttachment()
            
            // Оптимизация размера изображения
            let maxWidth = noteTextView.frame.width - 20
            let scale = maxWidth / selectedImage.size.width
            attachment.bounds = CGRect(x: 0, y: 0, width: selectedImage.size.width * scale, height: selectedImage.size.height * scale)
            attachment.image = selectedImage
            
            let imageString = NSAttributedString(attachment: attachment)
            let selectedRange = noteTextView.selectedRange
            let mutableText = NSMutableAttributedString(attributedString: noteTextView.attributedText)
            
            // Вставляем перевод строки и картинку с текущим стилем текста
            let lineBreak = NSAttributedString(string: "\n", attributes: noteTextView.typingAttributes)
            mutableText.insert(lineBreak, at: selectedRange.location)
            mutableText.insert(imageString, at: selectedRange.location + 1)
            mutableText.insert(lineBreak, at: selectedRange.location + 2)
            
            noteTextView.attributedText = mutableText
            noteTextView.selectedRange = NSRange(location: selectedRange.location + 3, length: 0)
            noteTextView.scrollRangeToVisible(NSRange(location: noteTextView.attributedText.length - 1, length: 1))
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    // MARK: - Загрузка существующей заметки с изображениями
    private func attributedTextWithExistingNote(_ note: Notes) -> NSAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20),
            .foregroundColor: UIColor.white
        ]
        
        let attributedString = NSMutableAttributedString(string: "\(note.title ?? "")\n", attributes: attributes)
        let bodyText = NSMutableAttributedString(string: "\(note.note ?? "")\n", attributes: attributes)
        attributedString.append(bodyText)
        
        if let imageDatas = note.imagesData as? [Data] {
            for data in imageDatas {
                if let image = UIImage(data: data) {
                    let attachment = NSTextAttachment()
                    let maxWidth = noteTextView.frame.width - 20
                    let scale = maxWidth / image.size.width
                    attachment.bounds = CGRect(x: 0, y: 0, width: image.size.width * scale, height: image.size.height * scale)
                    attachment.image = image
                    
                    let imageString = NSMutableAttributedString(string: "\n", attributes: attributes)
                    imageString.append(NSAttributedString(attachment: attachment))
                    imageString.append(NSAttributedString(string: "\n", attributes: attributes))
                    attributedString.append(imageString)
                }
            }
        }
        
        return attributedString
    }
    
    // MARK: - Done Button
    @objc func doneButtonTapped() {
        saveNote()
        isNoteSaved = true
        navigationController?.popViewController(animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParent && !isNoteSaved {
            saveNote()
        }
    }
    
    // MARK: - Сохранение заметки с изображениями
    private func saveNote() {
        guard let noteText = noteTextView.attributedText else { return }
        
        let components = noteText.string.components(separatedBy: "\n")
        let title = components.first ?? ""
        let noteTextWithoutTitle = components.dropFirst().joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
        let date = Date()
        
        // Сохраняем все изображения из текста
        var imagesData: [Data] = []
        noteText.enumerateAttribute(.attachment, in: NSRange(location: 0, length: noteText.length), options: []) { value, _, _ in
            if let attachment = value as? NSTextAttachment, let image = attachment.image {
                if let data = image.jpegData(compressionQuality: 0.8) {
                    imagesData.append(data)
                }
            }
        }
        
        if let existingNote = noteToEdit {
            do {
                if let noteObject = try CoreDataManager.shared.notesContext.existingObject(with: existingNote.objectID) as? Notes {
                    noteObject.title = title
                    noteObject.note = noteTextWithoutTitle
                    noteObject.date = date
                    noteObject.imagesData = imagesData as NSArray
                    CoreDataManager.shared.saveNotesContext()
                    NotificationCenter.default.post(name: .notesUpdated, object: nil)
                }
            } catch {
                print("Failed to update note with images: \(error)")
            }
        } else if let recipeId = idRecipe {
            let noteId = UUID().uuidString
            let note = Notes(context: CoreDataManager.shared.notesContext)
            note.title = title
            note.note = noteTextWithoutTitle
            note.date = date
            note.recipeID = recipeId
            note.noteID = noteId
            note.imagesData = imagesData as NSArray
            CoreDataManager.shared.saveNotesContext()
            NotificationCenter.default.post(name: .notesUpdated, object: nil)
        }
    }
}

