//
//  Photo.swift
//  PixelCity
//
//  Created by Sultan Karybaev on 10/28/18.
//  Copyright © 2018 Sultan Karybaev. All rights reserved.
//

import UIKit

class Photo: UIImageView {
    
    private var photo: UIImage!
    
    override init(image: UIImage?) {
        super.init(image: image)
        self.photo = image!
        buildup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buildup() {
        contentMode = .scaleAspectFill
        layer.masksToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
