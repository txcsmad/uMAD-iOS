//
//  EventViewController.swift
//  uMAD
//
//  Created by Andrew Chun on 1/29/15.
//  Copyright (c) 2015 com.MAD. All rights reserved.
//

import Foundation

class EventViewController: UIViewController {
    var image: UIImage!
    var event: Event!
    
    override init() {
        super.init()
    }
    
    init(image: UIImage, event: Event) {
        super.init()
        
        self.event = event
        self.image = image
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        var resizedImage: UIImage = image.resizedImageToSize(CGSizeMake(image.size.width * 0.35, image.size.height * 0.35))
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}