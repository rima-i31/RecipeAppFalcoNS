

import UIKit

class NotesTableViewCell: UITableViewCell {

    @IBOutlet weak var titleNote: UILabel!
    
    @IBOutlet weak var noteText: UILabel!
    
    var note: Notes? {
        didSet {
            guard let data = note else { return }
            titleNote.text = data.title
            noteText.text = data.note
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)


    }
    
    
}
