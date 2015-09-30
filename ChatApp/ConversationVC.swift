//
//  ConversationVC.swift
//  ChatApp
//
//  Created by Samuel Doherty on 8/29/15.
//  Copyright (c) 2015 ColombiaIOS. All rights reserved.
//

import UIKit

var otherName = ""
var otherProfile = ""

class ConversationVC: UIViewController , UIScrollViewDelegate , UITextViewDelegate {
    

    @IBOutlet weak var resultsScrollView: UIScrollView!
    @IBOutlet weak var frameMessageView: UIView!
    @IBOutlet weak var lineLbl: UILabel!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
//    @IBOutlet weak var blockBtn: UIBarButtonItem!
    
    
    var scrollViewOriginalY:CGFloat = 0
    var frameMessageOrignalY:CGFloat = 0
    
    let mLbl = UILabel(frame: CGRectMake(5, 8, 200, 20))
    
    var messageX:CGFloat = 37.0
    var messageY:CGFloat = 26.0
    var frameX:CGFloat = 32.0
    var frameY:CGFloat = 21.0
    
    var imgX:CGFloat = 3
    var imgY:CGFloat = 3
    
    var messageArray = [String]()
    var senderArray = [String]()
    
    var myImage:UIImage? = UIImage()
    var otherImage:UIImage? = UIImage()
    
    var resultsImageFiles = [PFFile]()
    var resultsImageFiles2 = [PFFile]()
    
    var isBlocked = false
    
    var blockBtn = UIBarButtonItem()
    var reportBtn = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let theWidth = view.frame.size.width
        let theHeight = view.frame.size.height
        
        resultsScrollView.frame = CGRectMake(0, 64, theWidth, theHeight-114)
        resultsScrollView.layer.zPosition = 20
        
        frameMessageView.frame = CGRectMake(0, resultsScrollView.frame.maxY, theWidth, 50)
        
        lineLbl.frame = CGRectMake(0, 0, theWidth, 1 )
        
        messageTextView.frame = CGRectMake(2, 1, self.frameMessageView.frame.size.width - 52, 48)
        sendButton.center = CGPointMake(frameMessageView.frame.size.width-30, 24)
        
        scrollViewOriginalY = self.resultsScrollView.frame.origin.y
        frameMessageOrignalY = self.frameMessageView.frame.origin.y
        
        self.title = otherProfile
        
        mLbl.text = "Type a message..."
        
        mLbl.backgroundColor = UIColor.clearColor()
        
        mLbl.textColor = UIColor.lightGrayColor()
        
        messageTextView.addSubview(mLbl)
        
//        refreshResults()
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide", name: UIKeyboardWillHideNotification, object: nil)
        
        let tapScrollViewGesture = UITapGestureRecognizer(target: self, action: "didTapScrollView")
        
        tapScrollViewGesture.numberOfTapsRequired = 1
        resultsScrollView.addGestureRecognizer(tapScrollViewGesture)
        
        
        // push 
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "getMessageFunc", name: "getMessage", object: nil)
        
        blockBtn.title = ""
        
        blockBtn = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("blockBtn_click"))
        reportBtn = UIBarButtonItem(title: "Report", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("reportBtn_click"))

        self.navigationItem.setRightBarButtonItems([reportBtn,blockBtn], animated: true)
//        self.navigationItem.rightBarButtonItems = [reportBtn,blockBtn] as? [UIBarButtonItem]
        
    }
    
    func getMessageFunc() {
//        refreshResults()
    }
    
    @IBAction func sendBtn_click(sender: UIButton) {
        if isBlocked {
            print("You are blocked")
            return
        }
        // change to alert
        if blockBtn.title == "Unblock" {
            print("you have blocked this user!! unblock to send message")
            return
        }
        if messageTextView.text == ""  {
            print("no text")
            // create alert
        } else {
           let messageDBTable = PFObject(className: "Messages")
            messageDBTable["sender"] = userName
            messageDBTable["other"] = otherName
            messageDBTable["message"] = self.messageTextView.text!
            messageDBTable.saveInBackgroundWithBlock {
                (success: Bool, error:NSError?) -> Void in
                
                if success {
                    // send push for new message
                    let uQuery:PFQuery = PFUser.query()!
                    uQuery.whereKey("username", equalTo: otherName)
                    let pushQuery:PFQuery = PFInstallation.query()!
                    pushQuery.whereKey("user", matchesQuery: uQuery)
                    let push:PFPush = PFPush()
                    push.setQuery(pushQuery)
                    push.setMessage("New Message")
                    do {
                        try push.sendPush()
                    } catch _ {
                    }
                    print("Push Sent")
                    
                    print("message sent")
                    self.messageTextView.text = ""
                    self.mLbl.hidden = false
                    self.refreshResults()
                }

            }
        }
    }
    
    func reportBtn_click() {
        print("report button clicked")
    }

    func blockBtn_click() {
        
        if blockBtn.title == "Block" {
            // alert to confirm
            let addBlock = PFObject(className: "Block")
            addBlock.setObject(userName, forKey: "user")
            addBlock.setObject(otherName, forKey: "blocked")
            addBlock.saveInBackgroundWithBlock{
                 (success:Bool, error:NSError?) -> Void in
            }
            self.blockBtn.title = "Unblock"
        } else {
            let query:PFQuery = PFQuery(className: "Block")
            query.whereKey("user", equalTo: userName)
            query.whereKey("blocked", equalTo: otherName)
            do {
                let objects = try query.findObjects()
                for object in objects {
                    object.deleteInBackgroundWithBlock {
                        (success:Bool, error:NSError?) -> Void in
                    }
                }
                self.blockBtn.title = "Block"
            } catch {
                print(error)
            }
            
            
      
        }
        
    }
    
    func didTapScrollView() {
        self.view.endEditing(true)
    }
    
    // hide message "placeholder" text
    func textViewDidChange(textView: UITextView) {
        if !messageTextView.hasText() {
            self.mLbl.hidden = false
        } else {
            self.mLbl.hidden = true
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if !messageTextView.hasText() {
            self.mLbl.hidden = false
        }
    }

    
    // animate scroll view up for keyboard
    func keyboardWasShown(notification:NSNotification){
        let dict:NSDictionary = notification.userInfo!
        let s:NSValue = dict.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue
        let rect:CGRect = s.CGRectValue()
        
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveLinear, animations: {
            self.resultsScrollView.frame.origin.y = self.scrollViewOriginalY - rect.height
            self.frameMessageView.frame.origin.y =  self.frameMessageOrignalY - rect.height
            
            let bottomOffset:CGPoint = CGPointMake(0, self.resultsScrollView.contentSize.height - self.resultsScrollView.bounds.size.height )
            self.resultsScrollView.setContentOffset(bottomOffset, animated: false)
            
            }, completion: {
                (finished:Bool) in
        
        })
    }
    func keyboardWillHide(notification:NSNotification) {
        
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveLinear, animations: {
            self.resultsScrollView.frame.origin.y = self.scrollViewOriginalY
            self.frameMessageView.frame.origin.y =  self.frameMessageOrignalY
            
            let bottomOffset:CGPoint = CGPointMake(0, self.resultsScrollView.contentSize.height - self.resultsScrollView.bounds.size.height )
            self.resultsScrollView.setContentOffset(bottomOffset, animated: false)
            
            }, completion: {
                (finished:Bool) in
                
        })
    }

    override func viewDidAppear(animated: Bool) {
        
        let checkQuery:PFQuery = PFQuery(className: "Block")
        checkQuery.whereKey("user", equalTo: otherName)
        checkQuery.whereKey("blocked", equalTo: userName)
        do {
            let objects2 = try checkQuery.findObjects()
            if objects2.count > 0 {
                isBlocked = true
            } else {
                isBlocked = false
            }
        } catch {
            print(error)
        }

        let blockedQuery = PFQuery(className: "Block")
        blockedQuery.whereKey("user", equalTo: userName)
        blockedQuery.whereKey("blocked", equalTo: otherName)
        do {
            let objects0 = try blockedQuery.findObjects()
            if objects0.count > 0 {
                self.blockBtn.title = "Unblock"
            } else {
                self.blockBtn.title = "Block"
            }
            
        } catch {
            print(error)
        }
        
        getUserImage(otherName)
        getUserImage(userName)
        self.refreshResults()
    }
    
    func getUserImage(username:String) {
        let query2 = PFQuery(className: "_User")
        query2.whereKey("username", equalTo: username)
        do {
            let objects = try query2.findObjects()
            self.resultsImageFiles2.removeAll(keepCapacity: false)
            for object in objects {
                self.resultsImageFiles2.append(object["photo"] as! PFFile)
                self.resultsImageFiles2[0].getDataInBackgroundWithBlock {
                    (imageData:NSData?, error:NSError?) -> Void in
                    
                    if error == nil {
                        if username == otherName {
                            self.otherImage = UIImage(data: imageData!)
                        } else {
                            self.myImage = UIImage(data: imageData!)
                        }
                    }
                }
            }
        } catch {
            print(error)
        }
    }
    
    func refreshResults() {
        messageX = 37.0
        messageY = 26.0
        frameX = 32.0
        frameY = 21.0
        
        messageArray.removeAll()
        senderArray.removeAll()
        
        let innerP1 = NSPredicate(format: "sender = %@ AND other = %@", userName, otherName)
        let innerQ1:PFQuery = PFQuery(className: "Messages", predicate: innerP1)
        
        let innerP2 = NSPredicate(format: "sender = %@ AND other = %@", otherName, userName)
        let innerQ2:PFQuery = PFQuery(className: "Messages", predicate: innerP2)
        
        let query = PFQuery.orQueryWithSubqueries([innerQ1,innerQ2])
        query.addAscendingOrder("createdAt")
        query.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error: NSError?) -> Void in
            if error == nil {
                for object in objects! {
                    self.senderArray.append(object["sender"] as! String)
                    self.messageArray.append(object["message"] as! String)
                }
            }
            
            for subView in self.resultsScrollView.subviews {
                subView.removeFromSuperview()
            }
            
            for var i = 0 ; i <= self.messageArray.count - 1; i++ {
                if self.senderArray[i] == userName {
                    self.makeChatLabel(self.messageArray[i], user: true)
                } else {
                    self.makeChatLabel(self.messageArray[i], user: false)
                }
                let bottomOffset:CGPoint = CGPointMake(0, self.resultsScrollView.contentSize.height - self.resultsScrollView.bounds.size.height)
                self.resultsScrollView.setContentOffset(bottomOffset, animated: false)
            }
        }
    }
    
    func makeChatLabel(messageText:String, user:Bool) {
        let thewidth = view.frame.size.width
        let messageLbl:UILabel = UILabel()
        messageLbl.frame = CGRectMake(0, 0, self.resultsScrollView.frame.size.width-94, CGFloat.max)
        if user {
            messageLbl.backgroundColor  = UIColor.groupTableViewBackgroundColor()
            messageLbl.textColor = UIColor.whiteColor()
        } else {
            messageLbl.backgroundColor  = UIColor.blueColor()
            messageLbl.textColor = UIColor.blackColor()
        }
        messageLbl.lineBreakMode = NSLineBreakMode.ByWordWrapping
        messageLbl.textAlignment = NSTextAlignment.Left
        messageLbl.numberOfLines = 0
        messageLbl.font = UIFont(name: "Helvetica Neuse", size: 17)
        messageLbl.text = messageText
        messageLbl.sizeToFit()
        messageLbl.layer.zPosition = 20
        if user {
            messageLbl.frame.origin.x = (self.resultsScrollView.frame.size.width - self.messageX) - messageLbl.frame.size.width
        } else {
            messageLbl.frame.origin.x = self.messageX
        }
        
        messageLbl.frame.origin.y   = self.messageY
        self.resultsScrollView.addSubview(messageLbl)
        self.messageY += messageLbl.frame.size.height + 30
        
        
        let frameLbl:UILabel = UILabel()
        if user {
            frameLbl.frame.size = CGSizeMake(messageLbl.frame.size.width + 10, messageLbl.frame.size.height + 10)
            frameLbl.frame.origin.x = (self.resultsScrollView.frame.size.width - self.frameX - frameLbl.frame.size.width)
            frameLbl.frame.origin.y = self.frameY
            frameLbl.backgroundColor = UIColor.blueColor()
        } else {
            frameLbl.frame = CGRectMake(self.frameX, self.frameY, messageLbl.frame.size.width+10, messageLbl.frame.size.height + 10)
            frameLbl.backgroundColor = UIColor.groupTableViewBackgroundColor()
        }
        
        frameLbl.backgroundColor = UIColor.groupTableViewBackgroundColor()
        frameLbl.layer.masksToBounds = true
        frameLbl.layer.cornerRadius = 10
        self.resultsScrollView.addSubview(frameLbl)
        self.frameY += frameLbl.frame.size.height + 20
        
        let img:UIImageView = UIImageView()
        
        if user {
            img.image = self.myImage
            img.frame.size = CGSizeMake(34, 34)
            
            img.frame.origin.x = (self.resultsScrollView.frame.size.width - self.imgX) - img.frame.size.width
            img.frame.origin.y = self.imgY
        } else {
            img.image = self.otherImage
            img.frame = CGRectMake(self.imgX, self.imgY, 34, 34)
        }
        img.layer.zPosition = 30
        img.layer.cornerRadius = img.frame.size.width/2
        img.clipsToBounds = true
        self.resultsScrollView.addSubview(img)
        self.imgY += frameLbl.frame.size.height + 20
        
        self.resultsScrollView.contentSize = CGSizeMake(thewidth, self.messageY)
    }

}