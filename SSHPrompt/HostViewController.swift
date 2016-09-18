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

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var hostField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var delegate: HostViewControllerDelegate?
    var host: Host?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        saveButton.isEnabled = false
        nameField.delegate = self
        hostField.delegate = self
        usernameField.delegate = self
        passwordField.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: AnyObject) {
        host = Host(name: nameField.text!, hostname: hostField.text!, andUser: usernameField.text!)
        if let pass = passwordField.text, !pass.isEmpty {
            self.host?.password = pass
        }
        self.delegate?.hostView(sender: self, savedHost: host!)
        self.dismiss(animated: true, completion: nil)
    }
//    @IBAction func connect(_ sender: AnyObject) {
//        UserDefaults.standard.setValue(self.hostField.text, forKey: "hostname")
//        UserDefaults.standard.setValue(self.usernameField.text, forKey: "username")
//        UserDefaults.standard.synchronize()
//        if let host = self.host {
////            if hostField.text == host.hostname && usernameField.text == host.username {
//            try? self.host!.deleteFromSecureStore()
//            self.host!.password = passwordField.text!
//            self.host!.hostname = hostField.text!
//            self.host!.username = usernameField.text!
//            try? self.host!.createInSecureStore()
////            }
//        } else {
//            self.host = Host(hostname: hostField.text!, andUser: usernameField.text!)
//            self.host!.password = passwordField.text!
//            try? self.host!.createInSecureStore()
//        }
//        
//        performSegue(withIdentifier: "connectSegue", sender: self)
//    }
    
    @IBAction func editChanged() {
        if let name = nameField.text, let host = hostField.text, let user = usernameField.text, !host.isEmpty && !user.isEmpty && !name.isEmpty {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//    }

}

extension HostViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameField {
            nameField.resignFirstResponder()
            hostField.becomeFirstResponder()
        }
        else if textField == hostField {
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

protocol HostViewControllerDelegate {
    func hostView(sender: HostViewController, savedHost host: Host)
}
