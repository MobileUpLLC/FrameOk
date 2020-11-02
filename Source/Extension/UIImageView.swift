//
//  UIImageView.swift

//
//  Created by Dmitry Smirnov on 28.06.2018.
//  Copyright © 2018 MobileUp LLC. All rights reserved.
//

import UIKit
import Kingfisher

public extension UIImageView {
    
    func addBlur() {
        
        guard let image = image else { return }
        
        let imageToBlur = CIImage(image: image)
        
        let blurfilter = CIFilter(name: "CIGaussianBlur")
        
        blurfilter?.setValue(imageToBlur, forKey: "inputImage")
        
        guard let resultImage = blurfilter?.value(forKey: "outputImage") as? CIImage else { return }
        
        let blurredImage = UIImage(ciImage: resultImage)
        
        self.image = blurredImage
        
        self.contentMode = .center
    }
    
    var url: String {
        
        set { setImageWithFadeAnimation(with: URL(string: newValue)) }
        get { return "" }
    }
    
    // MARK: - Public methods
    
    func setImage(with url: URL, placeholder: UIImage? = nil) {
        
        kf.setImage(with: url, placeholder: placeholder)
    }

    func setImageWithFadeAnimation(with url: URL?, placeholder: UIImage? = nil) {

        guard let url = url else {

            return
        }

        kf.setImage(

            with        : url,
            placeholder : placeholder,
            options     : [.transition(.fade(0.3))]
        )
    }

    func cancelDownloadTask() {

        kf.cancelDownloadTask()
    }
}
