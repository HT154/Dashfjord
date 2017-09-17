//
//  ArchiveKey.swift
//  SwiftKeychain
//
//  Created by Yanko Dimitrov on 11/13/14.
//  Copyright (c) 2014 Yanko Dimitrov. All rights reserved.
//

import Foundation

public class ArchiveKey: BaseKey {
    
    public var object: NSCoding?
    
    private var secretData: Data? {
        
        if let objectToArchive = object {
            
            return NSKeyedArchiver.archivedData(withRootObject: objectToArchive)
        }
        
        return nil
    }
    
    ///////////////////////////////////////////////////////
    // MARK: - Initializers
    ///////////////////////////////////////////////////////
    
    public init(keyName: String, object: NSCoding? = nil) {
        
        self.object = object
        super.init(name: keyName)
    }
    
    ///////////////////////////////////////////////////////
    // MARK: - KeychainItem
    ///////////////////////////////////////////////////////
    
    public override func makeQueryForKeychain(_ keychain: KeychainService) -> KeychainQuery {
        
        let query = KeychainQuery(keychain: keychain)
        
        query.addField(kSecClass, withValue: kSecClassGenericPassword)
        query.addField(kSecAttrService, withValue: keychain.serviceName)
        query.addField(kSecAttrAccount, withValue: name)
        
        return query
    }
    
    public override func fieldsToLock() -> [NSObject: AnyObject] {
        
        var fields = [NSObject: AnyObject]()
        
        if let data = secretData {
            fields[kSecValueData as NSString] = data as AnyObject?
        }
        
        return fields
    }
    
    public override func unlockData(_ data: Data) {
        
        object = NSKeyedUnarchiver.unarchiveObject(with: data) as? NSCoding
    }
}
