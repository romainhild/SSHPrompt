//
//  HostViewController.swift
//  SSHPrompt
//
//  Created by hild on 14/09/2016.
//  Copyright © 2016 hild. All rights reserved.
//

import UIKit

class HostViewController: UIViewController {

    @IBOutlet weak var hostField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var connectButton: UIBarButtonItem!
    
    let MyKeychainWrapper = KeychainWrapper()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        connectButton.enabled = false
        hostField.delegate = self
        usernameField.delegate = self
        passwordField.delegate = self
        
        if let host = NSUserDefaults.standardUserDefaults().valueForKey("host") as? String {
            hostField.text = host
        }
        if let user = NSUserDefaults.standardUserDefaults().valueForKey("username") as? String {
            usernameField.text = user
        }
        if let password = MyKeychainWrapper.myObjectForKey(kSecValueData) as? String {
            passwordField.text = password
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func connect(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setValue(self.hostField.text, forKey: "host")
        NSUserDefaults.standardUserDefaults().setValue(self.usernameField.text, forKey: "username")
        NSUserDefaults.standardUserDefaults().synchronize()
        MyKeychainWrapper.mySetObject(passwordField.text, forKey:kSecValueData)
        MyKeychainWrapper.writeToKeychain()
        performSegueWithIdentifier("connectSegue", sender: self)
    }
    
    @IBAction func editChanged() {
        if let host = hostField.text, user = usernameField.text, password = passwordField.text where !host.isEmpty && !user.isEmpty && !password.isEmpty {
            connectButton.enabled = true
        } else {
            connectButton.enabled = false
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "connectSegue" {
            let terminalView = segue.destinationViewController as! TerminalViewController
            terminalView.connectToHost(hostField.text!, withUsername: usernameField.text!, andPassword: passwordField.text!)
        }
    }

}

extension HostViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == hostField {
            hostField.resignFirstResponder()
            usernameField.becomeFirstResponder()
        }
        else if textField == usernameField {
            usernameField.resignFirstResponder()
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            passwordField.resignFirstResponder()
        }
        return true
    }
    
}
