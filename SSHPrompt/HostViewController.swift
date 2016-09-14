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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        connectButton.enabled = false
        hostField.delegate = self
        usernameField.delegate = self
        passwordField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func connect(sender: AnyObject) {
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
