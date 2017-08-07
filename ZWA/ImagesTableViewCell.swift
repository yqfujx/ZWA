//
//  ImagesTableViewCell.swift
//  ZWA
//
//  Created by osx on 2017/8/2.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit

class ImagesTableViewCell: UITableViewCell, UIScrollViewDelegate {

    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBAction func pageChanged(_ sender: Any?) {
        var rect = self.scrollView.frame
        rect.origin.x = CGFloat(self.pageControl.currentPage) * rect.size.width
        
        self.scrollView.scrollRectToVisible(rect, animated: true)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.pageControl.numberOfPages = 3
        let size = self.scrollView.frame.size
        self.scrollView.contentSize = CGSize(width: size.width * 3, height: size.height)
        self.scrollView.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        let time = offset.x / scrollView.frame.size.width
        self.pageControl.currentPage = Int(time)
    }
}
