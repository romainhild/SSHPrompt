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

        nameField.delegate = self
        hostField.delegate = self
        usernameField.delegate = self
        passwordField.delegate = self
        
        if let hostToEdit = self.host {
            self.title = hostToEdit.name
            self.nameField.text = hostToEdit.name
            self.hostField.text = hostToEdit.hostname
            self.usernameField.text = hostToEdit.username
            self.passwordField.text = hostToEdit.password
            self.saveButton.isEnabled = true
        } else {
            self.title = "New Host"
            saveButton.isEnabled = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        self.delegate?.hostViewCanceled(sender: self)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: AnyObject) {
        if let _ = self.host {
            self.host!.name = nameField.text!
            self.host!.hostname = hostField.text!
            self.host!.username = usernameField.text!
            self.host!.password = passwordField.text
            self.delegate?.hostView(sender: self, editedHost: self.host!)
        } else {
            host = Host(name: nameField.text!, hostname: hostField.text!, andUser: usernameField.text!)
            if let pass = passwordField.text, !pass.isEmpty {
                self.host?.password = pass
            }
            self.delegate?.hostView(sender: self, savedHost: host!)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
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
    func hostView(sender: HostViewController, editedHost host: Host)
    func hostViewCanceled(sender: HostViewController)
}
