
import Foundation
import UIKit

class ImageLoader {

    static let shared = ImageLoader()

    func loadImage(from urlString: String, into imageView: UIImageView, with indicator: UIActivityIndicatorView?) {
        imageView.alpha = 0
        indicator?.startAnimating()

        if let cachedImage = ImageCache.shared.getImage(forKey: urlString) {
            setImage(cachedImage, into: imageView, with: indicator)
        } else if urlString.contains("Documents") {
            loadLocalImage(urlString, into: imageView, with: indicator)
        } else {
            downloadImage(from: urlString, into: imageView, with: indicator)
        }
    }

    private func setImage(_ image: UIImage, into imageView: UIImageView, with indicator: UIActivityIndicatorView?) {
        imageView.image = image
        UIView.animate(withDuration: 0.5) { imageView.alpha = 1 }
        indicator?.stopAnimating()
    }

    private func loadLocalImage(_ urlString: String, into imageView: UIImageView, with indicator: UIActivityIndicatorView?) {
            let fileManager = FileManager.default
            let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileName = (urlString as NSString).lastPathComponent
            let fileURL = documentDirectory.appendingPathComponent(fileName)
            
            if fileManager.fileExists(atPath: fileURL.path),
               let image = UIImage(contentsOfFile: fileURL.path) {
                let resizedImage = ImageCache.shared.resizeImage(image: image)
                ImageCache.shared.setImage(resizedImage, forKey: urlString)
                setImage(resizedImage, into: imageView, with: indicator)
            } else {
                print("Failed to load image from path: \(fileURL.path)")
            }
        }


    private func downloadImage(from urlString: String, into imageView: UIImageView, with indicator: UIActivityIndicatorView?) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self = self, let data = data, let image = UIImage(data: data) else { return }
            let resizedImage = ImageCache.shared.resizeImage(image: image)
            ImageCache.shared.setImage(resizedImage, forKey: urlString)
            DispatchQueue.main.async { self.setImage(resizedImage, into: imageView, with: indicator) }
        }.resume()
    }
}
