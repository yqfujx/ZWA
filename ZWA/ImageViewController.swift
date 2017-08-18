//
//  ImageViewController.swift
//  ZWA
//
//  Created by osx on 2017/8/11.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {

    var image: UIImage!
    private var _imageView: UIImageView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    func layoutImageView() -> Void {
        if (self.image == nil) {
            return
        }
        
        let boundsSize = self.scrollView.bounds.size
        let vScale = self.image.size.height / boundsSize.height
        let hScale = self.image.size.width / boundsSize.width
        var frameToFit: CGRect
        var minimumScale = CGFloat(1.0)
        
        if ( self.image.size.height > self.image.size.width) {
            frameToFit = CGRect(x: 0, y: 0, width: self.image.size.width / vScale, height: boundsSize.height)
            minimumScale = min(boundsSize.width / frameToFit.size.width, CGFloat(1.0))
        }
        else {
            frameToFit = CGRect(x: 0, y: 0, width: boundsSize.width, height: self.image.size.height / hScale)
            minimumScale = min(boundsSize.height / frameToFit.size.height, CGFloat(1.0))
        }
        
        if (frameToFit.size.width < boundsSize.width) {
            frameToFit.origin.x = (boundsSize.width - frameToFit.size.width) / 2
        }
        else {
            frameToFit.origin.x = 0
        }
        
        if (frameToFit.size.height < boundsSize.height) {
            frameToFit.origin.y = (boundsSize.height  - frameToFit.size.height) / 2
        }
        else {
            frameToFit.origin.y = 0
        }
        
        var frameToCenter = self._imageView.frame
        self.scrollView.minimumZoomScale = minimumScale
        
        if ((frameToCenter.size.width < boundsSize.width && frameToCenter.size.height < boundsSize.height) || self.scrollView.zoomScale <= 1) {
            frameToCenter = frameToFit
            //            _imageView.transform = CGAffineTransformIdentity;
            self.scrollView.zoomScale = 1
        }
        else  {
            // center horizontally
            if (frameToCenter.size.width < boundsSize.width) {
                frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2
            }
            else {
                frameToCenter.origin.x = 0
            }
            
            // center vertically
            if (frameToCenter.size.height < boundsSize.height) {
                frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2
            }
            else {
                frameToCenter.origin.y = 0
            }
            
            let newScale = frameToCenter.size.width / frameToFit.size.width
            self.scrollView.zoomScale = newScale
            //            _imageView.transform = CGAffineTransformMakeScale(newScale, newScale);
        }
        
        
        self._imageView.frame = frameToCenter;
        self.scrollView.contentSize = frameToCenter.size;
    }
    
    func handleTap(gesture: UITapGestureRecognizer) ->Void {
        if (gesture.state == .ended) {
            self.navigationController?.popViewController(animated: true)
        }
    }

    
    // MARK: - 重载
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self._imageView = UIImageView(image: self.image)
        self._imageView.layer.contentsGravity = kCAGravityResizeAspect;
        self._imageView.frame = self.scrollView.frame;
        self._imageView.center = CGPoint(x: self.scrollView.frame.midX, y: self.scrollView.frame.midY);
        
        self.scrollView.addSubview(self._imageView)
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 5.0
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(gesture:)))
        self.scrollView.addGestureRecognizer(gesture)
}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        self.layoutImageView()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self._imageView
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        let boundsSize = scrollView.bounds.size;
        var frameToCenter = view!.frame;
        
        // center horizontally
        if (frameToCenter.size.width < boundsSize.width) {
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2
        }
        else {
            frameToCenter.origin.x = 0
        }
        
        // center vertically
        if (frameToCenter.size.height < boundsSize.height) {
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2
        }
        else {
            frameToCenter.origin.y = 0
        }
        
        UIView.beginAnimations(nil, context: nil)
        view!.frame = frameToCenter;
        UIView.commitAnimations()
    }
}
