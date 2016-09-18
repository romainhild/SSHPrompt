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
    
    func connect(toHost host: Host) {
        self.sshQueue.async {
            self.session = NMSSHSession(host: host.hostname, andUsername: host.username)
            self.session.delegate = self
            self.session.connect()
            if self.session.isConnected {
                if let password = host.password {
                    self.session.authenticate(byPassword: password)
                } 
                
                if self.session.isAuthorized {
                    self.session.channel.delegate = self
                    self.session.channel.requestPty = true
                    
                    do {
                        try self.session.channel.startShell()
                    } catch {
                        print("error starting shell")
                    }
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
        if message.trimmingCharacters(in: .newlines) == lastCommand.trimmingCharacters(in: .newlines) {
            print("read last command")
            lastCommand = ""
        } else {
            appendTextTerminal(message)
        }
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
        if text.characters.count == 0 {
            if self.lastCommand.characters.count > 0 {
                lastCommand.remove(at: lastCommand.index(before: lastCommand.endIndex))
                return true
            } else {
                return false
            }
        }
        
        self.lastCommand.append(text)
        
        if text == "\n" {
            sshQueue.async {
                do {
                    try self.session.channel.write(self.lastCommand)
                } catch {
                    print("error command : \(self.lastCommand)")
                }
            }
        }
        
        return true
    }
}

