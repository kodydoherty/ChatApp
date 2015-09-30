//
//  UserViewController.swift
//  ChatApp
//
//  Created by Samuel Doherty on 8/27/15.
//  Copyright (c) 2015 ColombiaIOS. All rights reserved.
//

import UIKit

var userName = ""

class UserViewController: UIViewController,  UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var resultsTable: UITableView!
    var resultsUsernameArray = [String]()
    var resultsProfileNameArray = [String]()
    var resultsImageFiles = [PFFile]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let theWidth = view.frame.size.width
        let theHeight = view.frame.size.height
        
        resultsTable.frame = CGRectMake(0, 0, theHeight, theHeight-64)
        
        userName = PFUser.currentUser()!.username!
        
    }
    
    override func viewDidAppear(animated: Bool) {
        resultsImageFiles.removeAll(keepCapacity: false)
        resultsProfileNameArray.removeAll(keepCapacity: false)
        resultsUsernameArray.removeAll(keepCapacity: false)
        
        let predicate = NSPredicate(format: "username != '"+userName+"'")
        let query = PFQuery(className: "_User", predicate: predicate)
    
        do {
            if let objects = try query.findObjects() as? [PFUser] {
                for object in objects{
                    self.resultsUsernameArray.append(object.username!)
                    self.resultsProfileNameArray.append(object["profileName"] as! String)
                    self.resultsImageFiles.append(object["photo"] as! PFFile)
                    
                    self.resultsTable.reloadData()
                }
            }
           
        } catch {
            print(error)
        }

        

    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.hidesBackButton = true
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! resultsCell
        otherName = cell.userNameLbl.text!
        otherProfile = cell.profileNameLbl.text!
        self.performSegueWithIdentifier("goToConversationVC", sender: self)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsUsernameArray.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = resultsTable.dequeueReusableCellWithIdentifier("Cell") as! resultsCell
        cell.userNameLbl.text = self.resultsUsernameArray[indexPath.row]
        cell.profileNameLbl.text = self.resultsProfileNameArray[indexPath.row]
        resultsImageFiles[indexPath.row].getDataInBackgroundWithBlock {
            (imageData:NSData?, error:NSError?) -> Void in
            if error == nil {
                let image = UIImage(data: imageData!)
                cell.profileImg.image = image
            }
        }
        return cell
    }
    @IBAction func logOut(sender: UIBarButtonItem) {
        
        PFUser.logOut()
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
}
