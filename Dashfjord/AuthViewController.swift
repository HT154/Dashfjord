//
//  AuthViewController.swift
//  Dashfjord
//
//  Created by Joshua Basch on 11/27/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Cocoa

class AuthViewController: NSViewController {

    @IBAction func loginButton(_ sender: AnyObject!) {
        (NSApp.delegate as! AppDelegate).authorize()
    }
    
    @IBAction func registerButton(_ sender: AnyObject!) {
        NSWorkspace.shared().open(URL(string: "https://www.tumblr.com/register")!)
    }
    
}
