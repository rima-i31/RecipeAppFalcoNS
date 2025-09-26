
import Foundation
import UIKit

class ImageCache {
    static let shared = ImageCache()
    
    private var cache = [String: UIImage]()
    private init() {}
    
    func getImage(forKey key: String) -> UIImage? {
        return cache[key]
    }
    
    func setImage(_ image: UIImage, forKey key: String) {
        cache[key] = image
    }
    
    func resizeImage(image: UIImage) -> UIImage {
        let targetSize = getTargetSize()
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        let rect = CGRect(origin: .zero, size: newSize)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    func clearCache() {
        cache.removeAll()
    }
    private func getTargetSize() -> CGSize {
        let screenHeight = UIScreen.main.nativeScale
        return CGSize(width: 100 * screenHeight, height: 100 * screenHeight)
    }
    
}


