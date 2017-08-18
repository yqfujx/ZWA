//
//  ImagesTableViewCell.swift
//  ZWA
//
//  Created by osx on 2017/8/2.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit

class ImagesTableViewCell: UITableViewCell {

    @IBOutlet weak var imageView0: UIImageView!
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var indicator0: UIActivityIndicatorView!
    @IBOutlet weak var indicator1: UIActivityIndicatorView!
    @IBOutlet weak var indicator2: UIActivityIndicatorView!
    
    private weak var _target: AnyObject?
    private var _tapSelector: Selector?
    
    func addTarget(target: AnyObject, selector: Selector) -> Void {
        self._target = target
        self._tapSelector = selector
    }
    
    func imageViewTaped(gesture: UITapGestureRecognizer) -> Void {
        if gesture.state == .recognized {
            if self._target != nil && self._target!.responds(to: self._tapSelector) {
                var index: Int?
                if gesture.view === self.imageView0 {
                    index = 0
                }
                else if gesture.view === self.imageView1 {
                    index = 1
                }
                else if gesture.view === self.imageView2 {
                    index = 2
                }
                
                _ = self._target?.perform(self._tapSelector, with: NSNumber(value: index!))
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let imageViews = [self.imageView0, self.imageView1, self.imageView2]
        
        for iv in imageViews {
            iv?.layer.borderWidth = 1
            iv?.layer.borderColor = UIColor.lightGray.cgColor
            iv?.image = UIImage(named: "image_placeholder.png")
            iv?.isUserInteractionEnabled = true
            
            let gesture = UITapGestureRecognizer(target: self, action: #selector(self.imageViewTaped(gesture:)))
            iv?.addGestureRecognizer(gesture)
        }
    }
    
    override func prepareForReuse() {
        self.imageView0.image = UIImage(named: "image_placeholder.png")
        self.imageView1.image = UIImage(named: "image_placeholder.png")
        self.imageView2.image = UIImage(named: "image_placeholder.png")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
