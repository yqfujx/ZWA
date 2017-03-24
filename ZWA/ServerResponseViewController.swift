//
//  ServerResponseViewController.swift
//  ZWA
//
//  Created by mac on 2017/3/9.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit


class ServerResponseViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
//    var webService: WebService?
    
    func doRequest() -> Void {
        /*
        if self.webService != nil {
            weak var weakSelf = self
            let url = (webService?.urlString)!

            let manager = AFHTTPSessionManager()
            manager.requestSerializer = AFHTTPRequestSerializer()
            manager.responseSerializer = AFHTTPResponseSerializer()
           
            manager.responseSerializer.acceptableContentTypes = NSSet(objects: "text/html", "text/xml", "application/json", "text/json", "text/javascript") as? Set<String>
            manager.post(url, parameters: webService?.params, progress: nil, success: { (task:URLSessionDataTask, obj: Any) in
                
                
                let results = String(data: obj as! Data, encoding: .utf8)!
                weakSelf?.textView.text = "\((weakSelf?.webService?.urlString)!) \n \(weakSelf?.webService?.params)\n\n\n\(results)"
            }, failure: { (task: URLSessionDataTask?, error: Error) in
                weakSelf?.textView.text = "Failed\n" + error.localizedDescription
            })
 
        }
        */
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        doRequest()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
