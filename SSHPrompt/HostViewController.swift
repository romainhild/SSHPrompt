//
//  HostViewController.swift
//  SSHPrompt
//
//  Created by hild on 14/09/2016.
//  Copyright © 2016 hild. All rights reserved.
//

import UIKit
import Locksmith

class HostViewController: UIViewController {

    @IBOutlet weak var hostField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var connectButton: UIBarButtonItem!
    @IBOutlet weak var rememberSwitch: UISwitch!
    
    var host: Host?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        connectButton.isEnabled = false
        hostField.delegate = self
        usernameField.delegate = self
        passwordField.delegate = self
        
        var hasHostname: Bool = false
        var hasUsername: Bool = false
        
        if let hostname = UserDefaults.standard.value(forKey: "hostname") as? String {
            hostField.text = hostname
            hasHostname = true
        }
        if let user = UserDefaults.standard.value(forKey: "username") as? String {
            usernameField.text = user
            hasUsername = true
        }
        if hasUsername && hasHostname && rememberSwitch.isOn {
            host = Host(hostname: hostField.text!, andUser: usernameField.text!)
            let dict = host!.readFromSecureStore()
            if let data = dict?.data, let password = data["password"] as? String {
                passwordField.text = password
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func connect(_ sender: AnyObject) {
        UserDefaults.standard.setValue(self.hostField.text, forKey: "hostname")
        UserDefaults.standard.setValue(self.usernameField.text, forKey: "username")
        UserDefaults.standard.synchronize()
        if let host = self.host {
//            if hostField.text == host.hostname && usernameField.text == host.username {
            try? self.host!.deleteFromSecureStore()
            self.host!.password = passwordField.text!
            self.host!.hostname = hostField.text!
            self.host!.username = usernameField.text!
            try? self.host!.createInSecureStore()
//            }
        } else {
            self.host = Host(hostname: hostField.text!, andUser: usernameField.text!)
            self.host!.password = passwordField.text!
            try? self.host!.createInSecureStore()
        }
        
        performSegue(withIdentifier: "connectSegue", sender: self)
    }
    
    @IBAction func editChanged() {
        if let host = hostField.text, let user = usernameField.text, let password = passwordField.text , !host.isEmpty && !user.isEmpty && !password.isEmpty {
            connectButton.isEnabled = true
        } else {
            connectButton.isEnabled = false
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "connectSegue" {
            let terminalView = segue.destination as! TerminalViewController
            terminalView.connectToHost(hostField.text!, withUsername: usernameField.text!, andPassword: passwordField.text!)
        }
    }

}

extension HostViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
