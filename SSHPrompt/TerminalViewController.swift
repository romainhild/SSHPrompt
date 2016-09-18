//
//  ViewController.swift
//  SSHPrompt
//
//  Created by hild on 11/09/2016.
//  Copyright © 2016 hild. All rights reserved.
//

import UIKit

class TerminalViewController: UIViewController {
    
    var session: NMSSHSession!
    let sshQueue: DispatchQueue = DispatchQueue(label: "SSHPrompt.queue", attributes: [])
    var lenghtOfText: Int = 0
    var lastCommand: String = ""

    @IBOutlet weak var terminalTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let logger = NMSSHLogger.sharedLogger()
        //logger.logLevel = .Verbose
    }
    
    func connectToHost(_ host: String, withUsername user: String, andPassword password: String) {
        self.sshQueue.async {
            self.session = NMSSHSession(host: host, andUsername: user)
            self.session.delegate = self
            self.session.connect()
            if self.session.isConnected {
                self.session.authenticate(byPassword: password)
                
                if self.session.isAuthorized {
                    self.session.channel.delegate = self
                    self.session.channel.requestPty = true
                    
                    do {
                        try self.session.channel.startShell()
                    } catch {
                        print("error")
                    }
                    //                session.sftp.connect()
                    //
                    //                let remoteFileList = session.sftp.contentsOfDirectoryAtPath("/")
                    //                for file in remoteFileList {
                    //                    print(file.filename)
                    //                }
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func appendTextTerminal(_ text: String) {
        DispatchQueue.main.async {
            self.lenghtOfText += text.lengthOfBytes(using: String.Encoding.utf8)
            self.terminalTextView.text = self.terminalTextView.text + text
        }
    }

}

extension TerminalViewController: NMSSHChannelDelegate {
    func channel(_ channel: NMSSHChannel!, didReadData message: String!) {
        print("channelDidReadData : '\(message)'")
        appendTextTerminal(message)
    }
    
    func channel(_ channel: NMSSHChannel!, didReadError error: String!) {
        print("channelDidReadError: \(error)")
    }
    
    func channelShellDidClose(_ channel: NMSSHChannel!) {
        print("channelShellDidClose")
    }
    
    func channel(_ channel: NMSSHChannel!, didReadRawData data: Data!) {
        print("channelDidReadRawData")
    }
    
    func channel(_ channel: NMSSHChannel!, didReadRawError error: Data!) {
        print("channelDidReadRawError")
    }
    
}

extension TerminalViewController: NMSSHSessionDelegate {
    func session(_ session: NMSSHSession!, didDisconnectWithError error: Error!) {
        print("sessionDidDisconnectWithError: \(error.localizedDescription)")
    }
    
    func session(_ session: NMSSHSession!, keyboardInteractiveRequest request: String!) -> String! {
        print("sessionsKeyboardInteractiveRequest: \(request)")
        return request
    }
    
    func session(_ session: NMSSHSession!, shouldConnectToHostWithFingerprint fingerprint: String!) -> Bool {
        print("sessionsShouldConnectToHostWithFingerprint: \(fingerprint)")
        return true
    }
}

extension TerminalViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        //print("replace text '\(text)' in range \(range.location)-\(range.location+range.length) with length \(self.lenghtOfText)")
        if range.location < self.lenghtOfText {
            return false
        } else {
            lastCommand += text
            if text != "\n" {
                return true
            } else {
                if let start = textView.position(from: textView.beginningOfDocument, offset: self.lenghtOfText) {
                    let end = textView.endOfDocument
                    if let commandRange = textView.textRange(from: start, to: end), let command = textView.text(in: commandRange) {
                        print("command : \(command)")
                        sshQueue.async {
                            do {
                                try self.session.channel.write(command)
                                try self.session.channel.write("\n")
                            } catch {
                                print("error command")
                            }
                        }
                    }
                }
                self.lenghtOfText += lastCommand.lengthOfBytes(using: String.Encoding.utf8) + 1
                lastCommand = ""
                return false
            }
        }
    }
}

