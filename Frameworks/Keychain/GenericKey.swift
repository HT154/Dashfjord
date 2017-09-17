//
//  GenericKey.swift
//  SwiftKeychain
//
//  Created by Yanko Dimitrov on 11/12/14.
//  Copyright (c) 2014 Yanko Dimitrov. All rights reserved.
//

import Foundation

public class GenericKey: BaseKey {
    
    public var value: NSString?
    
    private var secretData: Data? {
        
        return value?.data(using: String.Encoding.utf8.rawValue)
    }
    
    ///////////////////////////////////////////////////////
    // MARK: - Initializers
    ///////////////////////////////////////////////////////
    
    public init(keyName: String, value: NSString? = nil) {
        
        self.value = value
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
        
        value = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
    }
}
