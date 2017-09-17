//
//  KeychainService.swift
//  SwiftKeychain
//
//  Created by Yanko Dimitrov on 11/11/14.
//  Copyright (c) 2014 Yanko Dimitrov. All rights reserved.
//

import Foundation

public protocol KeychainService {
    
    var accessMode: NSString {get}
    var serviceName: String {get}
    var accessGroup: String? {get set}
    
    func add(_ key: KeychainItem) -> Error?
    func update(_ key: KeychainItem) -> Error?
    func remove(_ key: KeychainItem) -> Error?
    func get<T: BaseKey>(_ key: T) -> (item: T?, error: Error?)
}
