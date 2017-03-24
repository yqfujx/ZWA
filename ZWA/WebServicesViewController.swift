//
//  WebServicesViewController.swift
//  ZWA
//
//  Created by mac on 2017/3/8.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit

class WebServicesViewController: UITableViewController {
    
//    var webServices: [WebService] = []

    
    // MARK: initial webservices
    func initWebServices() -> Void {
        /*
        var ws = WebService(host: "http://192.134.2.166:8080")
        ws = "http://www.webservicex.net/globalweather.asmx/GetCitiesByCountry"
         ws.params = ["CountryName": "china"]
        self.webServices.append(ws)
        
        ws = WebService(urlString: "http://www.baidu.com/s", params: ["sl_lang":"en", "rsv_srlang": "en", "rsv_rq" :"en"])
        self.webServices.append(ws)
        
        ws = WebService(urlString: "http://192.134.2.166:8080/Service1.asmx/AddMethod", params: ["A": 123, "B": 456])
        self.webServices.append(ws)
        
        ws = WebService(urlString: "http://192.134.2.166:8080/Service1.asmx/EchoMessage", params: ["msg": "This content will return back from server."])
        self.webServices.append(ws)
        
        ws = WebService(urlString: "http://192.134.2.166:8080/Service1.asmx/HelloWorld", params: nil)
        self.webServices.append(ws)
        
        ws = WebService(urlString: "http://192.134.2.166:8080/Service1.asmx/HelloWorld1", params: nil)
        self.webServices.append(ws)
        
        ws = WebService(urlString: "http://192.134.2.166:8080/Service1.asmx/OverWtNum", params: nil)
        self.webServices.append(ws)
        
        ws = WebService(urlString: "http://192.134.2.166:8080/Service1.asmx/test", params: nil)
        self.webServices.append(ws)
        
        ws = WebService(urlString: "http://192.134.2.166:8080/Service1.asmx/testdata", params: nil)
        self.webServices.append(ws)
 */
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectWebServiceSegue" {
            let vc = segue.destination as! ServerResponseViewController
            let indexPath = self.tableView.indexPathForSelectedRow
//            vc.webService = self.webServices[(indexPath?.row)!]
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.initWebServices()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    /*
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.webServices.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        // Configure the cell...
 //       let ws = self.webServices[indexPath.row]
        
 //       cell.textLabel?.text = ws.urlString

        return cell
    }
 */
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
