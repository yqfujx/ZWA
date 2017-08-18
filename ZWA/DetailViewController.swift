//
//  DetailViewController.swift
//  ZWA
//
//  Created by osx on 2017/8/2.
//  Copyright © 2017年 zonjli. All rights reserved.
//

import UIKit

class DetailViewController: UITableViewController {

    var data: LiveData!
    lazy var  imageService: PhotoService = {
        return PhotoService()
    }()
    
    func imageViewTapped(indexNumber: NSNumber) -> Void {
        let index = indexNumber.intValue
        let url = String(format: "%@/%@_%d.jpg", self.data.picUrl, self.data.RID, index + 1)
        let record = self.imageService.record(forUrl: url)
        
        if record.state == .downloaded {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "ImageViewController") as! ImageViewController
            controller.modalPresentationStyle = .fullScreen
            controller.modalTransitionStyle = .coverVertical
            controller.image = record.image
            controller.title = String(format: "照片 %d", index + 1)
            
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.title = "明细"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.imageService.stop()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
         return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 11
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let isTextCell = (indexPath.row != 10)
        let identifier = (isTextCell ? "TextCell" : "ImageCell")
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)

        // Configure the cell...
        if isTextCell {
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "记录号:"
                cell.detailTextLabel?.text = self.data.RID
            case 1:
                cell.textLabel?.text = "站点编号:"
                cell.detailTextLabel?.text = self.data.stationID
            case 2:
                cell.textLabel?.text = "车牌号:"
                cell.detailTextLabel?.text = self.data.carNo
            case 3:
                cell.textLabel?.text = "车道号:"
                cell.detailTextLabel?.text = self.data.carLane
            case 4:
                cell.textLabel?.text = "超重率:"
                cell.detailTextLabel?.text = String(format: "%.f%%", self.data.overWeightRate)
            case 5:
                cell.textLabel?.text = "超重:"
                cell.detailTextLabel?.text = String(format: "%.f", self.data.overWeight)
            case 6:
                cell.textLabel?.text = "超长:"
                cell.detailTextLabel?.text = String(format: "%.f", self.data.overLength)
            case 7:
                cell.textLabel?.text = "超宽:"
                cell.detailTextLabel?.text = String(format: "%.f", self.data.overWidth)
            case 8:
                cell.textLabel?.text = "超高:"
                cell.detailTextLabel?.text = String(format: "%.f", self.data.overHeight)
            case 9:
                cell.textLabel?.text = "检测时间:"
                cell.detailTextLabel?.text = self.data.checkDatetime.string(with: "yyyy-MM-dd HH:mm:ss")
            default:
                break
            }
        }
        else {
            let cell = cell as! ImagesTableViewCell
            cell.addTarget(target: self, selector: #selector(self.imageViewTapped(indexNumber:)))
            
            let imageViews = [cell.imageView0, cell.imageView1, cell.imageView2]
            let indicators = [cell.indicator0, cell.indicator1, cell.indicator2]
            
            for i in 0 ..< 3 {
                let url = String(format: "%@/%@_%d.jpg", self.data.picUrl, self.data.RID, i + 1)
                let record = self.imageService.record(forUrl: url)
                imageViews[i]?.image = record.thumbnail
                
                switch record.state {
                case .downloaded:
                    indicators[i]?.stopAnimating()
                case .failed:
                    indicators[i]?.stopAnimating()
                case .new:
                    indicators[i]?.startAnimating()
                    self.imageService.download(record: record, completion: { [weak tableView] (record) in
                        tableView?.reloadRows(at: [indexPath], with: .fade)
                    })
//                default:
//                    break
                }
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 10 ? 106 : 44
    }

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
