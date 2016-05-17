//
//  ModelType.swift
//  Dashfjord
//
//  Created by Joshua Basch on 9/20/15.
//  Copyright © 2015 HT154. All rights reserved.
//

import Foundation

func modelizeSingle<T: ModelType>(raw: JSONDict) -> T {
    return T(dict: raw)
}

func modelize<T: ModelType>(raw: [JSONDict]) -> [T] {
    return raw.map() { (dict: JSONDict) -> T in
        return modelizeSingle(dict)
    }
}

protocol ModelType {
    
    init(dict: JSONDict)
    
}