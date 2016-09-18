//
//  Host.swift
//  SSHPrompt
//
//  Created by hild on 18/09/2016.
//  Copyright © 2016 hild. All rights reserved.
//

import Foundation
import Locksmith

class Host: NSObject, GenericPasswordSecureStorable, CreateableSecureStorable, ReadableSecureStorable, DeleteableSecureStorable {
    var hostname: String
    var username: String
    var password: String?
    
    var service: String { return hostname }
    var account: String { return username }
    
    var data: [String : Any] {
        if let pw = self.password {
            return ["password": pw]
        } else {
            return [String: Any]()
        }
    }
    
    init(hostname host: String, andUser user: String) {
        self.hostname = host
        self.username = user
        
        super.init()
    }
}
