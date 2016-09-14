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
    let sshQueue: dispatch_queue_t = dispatch_queue_create("SSHPrompt.queue", DISPATCH_QUEUE_SERIAL)
    var lenghtOfText: Int = 0
    var lastCommand: String = ""

    @IBOutlet weak var terminalTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let logger = NMSSHLogger.sharedLogger()
        //logger.logLevel = .Verbose
    }
    
    func connectToHost(host: String, withUsername user: String, andPassword password: String) {
        dispatch_async(self.sshQueue) {
            self.session = NMSSHSession(host: host, andUsername: user)
            self.session.delegate = self
            self.session.connect()
            if self.session.connected {
                self.session.authenticateByPassword(password)
                
                if self.session.authorized {
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

    func appendTextTerminal(text: String) {
        dispatch_async(dispatch_get_main_queue()) {
            self.lenghtOfText += text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
            self.terminalTextView.text = self.terminalTextView.text + text
        }
    }

}

extension TerminalViewController: NMSSHChannelDelegate {
    func channel(channel: NMSSHChannel!, didReadData message: String!) {
        print("channelDidReadData : '\(message)'")
        appendTextTerminal(message)
    }
    
    func channel(channel: NMSSHChannel!, didReadError error: String!) {
        print("channelDidReadError: \(error)")
    }
    
    func channelShellDidClose(channel: NMSSHChannel!) {
        print("channelShellDidClose")
    }
    
    func channel(channel: NMSSHChannel!, didReadRawData data: NSData!) {
        print("channelDidReadRawData")
    }
    
    func channel(channel: NMSSHChannel!, didReadRawError error: NSData!) {
        print("channelDidReadRawError")
    }
    
}

extension TerminalViewController: NMSSHSessionDelegate {
    func session(session: NMSSHSession!, didDisconnectWithError error: NSError!) {
        print("sessionDidDisconnectWithError: \(error.localizedDescription)")
    }
    
    func session(session: NMSSHSession!, keyboardInteractiveRequest request: String!) -> String! {
        print("sessionsKeyboardInteractiveRequest: \(request)")
        return request
    }
    
    func session(session: NMSSHSession!, shouldConnectToHostWithFingerprint fingerprint: String!) -> Bool {
        print("sessionsShouldConnectToHostWithFingerprint: \(fingerprint)")
        return true
    }
}

extension TerminalViewController: UITextViewDelegate {
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        //print("replace text '\(text)' in range \(range.location)-\(range.location+range.length) with length \(self.lenghtOfText)")
        if range.location < self.lenghtOfText {
            return false
        } else {
            lastCommand += text
            if text != "\n" {
                return true
            } else {
                if let start = textView.positionFromPosition(textView.beginningOfDocument, offset: self.lenghtOfText) {
                    let end = textView.endOfDocument
                    if let commandRange = textView.textRangeFromPosition(start, toPosition: end), command = textView.textInRange(commandRange) {
                        print("command : \(command)")
                        dispatch_async(sshQueue) {
                            do {
                                try self.session.channel.write(command)
                                try self.session.channel.write("\n")
                            } catch {
                                print("error command")
                            }
                        }
                    }
                }
                self.lenghtOfText += lastCommand.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) + 1
                lastCommand = ""
                return false
            }
        }
    }
}

