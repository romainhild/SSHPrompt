//
//  Host.swift
//  SSHPrompt
//
//  Created by hild on 18/09/2016.
//  Copyright © 2016 hild. All rights reserved.
//

import Foundation
import Locksmith

class Host: NSObject, NSCoding, GenericPasswordSecureStorable, CreateableSecureStorable, ReadableSecureStorable, DeleteableSecureStorable {
    var name: String
    var hostname: String
    var username: String
    var password: String? {
        get {
            if let result = self.readFromSecureStore(), let pw = result.data?["password"] as? String {
                return pw
            } else {
                return nil
            }
        }
        set {
            try? self.deleteFromSecureStore()
            if let newValue = newValue {
                print(newValue)
                self.data = ["password": newValue]
                try? self.createInSecureStore()
            }
            //self.data = [String: Any]()
        }
    }
    
    var service: String { return hostname }
    var account: String { return username }
    
    var data = [String : Any]()
    
    init(name: String, hostname host: String, andUser user: String) {
        self.name = name
        self.hostname = host
        self.username = user
        
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        if let name = aDecoder.decodeObject(forKey: "name") as? String {
            self.name = name
        } else {
            return nil
        }
        if let host = aDecoder.decodeObject(forKey: "hostname") as? String {
            self.hostname = host
        } else {
            return nil
        }
        if let user = aDecoder.decodeObject(forKey: "user") as? String {
            self.username = user
        } else {
            return nil
        }
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(hostname, forKey: "hostname")
        aCoder.encode(username, forKey: "user")
    }
}
