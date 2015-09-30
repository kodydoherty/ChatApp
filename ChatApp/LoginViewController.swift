//
//  ViewController.swift
//  ChatApp
//
//  Created by Samuel Doherty on 8/26/15.
//  Copyright (c) 2015 ColombiaIOS. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var welcomelbl: UILabel!
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var signupBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let theWidth = view.frame.size.width
        let theHeight = view.frame.size.height
        
        welcomelbl.center = CGPointMake(theWidth/2, 130)
        usernameTxt.frame = CGRectMake(16, 200, theWidth-32, 30)
        passwordTxt.frame = CGRectMake(16, 240, theWidth-32, 30)
        loginBtn.center = CGPointMake(theWidth/2, 330)
        signupBtn.center = CGPointMake(theWidth/2, theHeight-30)
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = true
    }

    @IBAction func loginButton(sender: UIButton) {

           PFUser.logInWithUsernameInBackground(usernameTxt.text!, password:passwordTxt.text!) {
                (user: PFUser?, error: NSError?) -> Void in
                if user != nil {
                    let instalation:PFInstallation = PFInstallation.currentInstallation()
                    instalation["user"] = PFUser.currentUser()
                    do {
                        try instalation.save()
                    } catch {
                        print(error)
                    }
                    
                    self.performSegueWithIdentifier("goToUserVC", sender: self)
                } else {
                    print(error)
                }
            }
    }
}

