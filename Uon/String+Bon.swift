//
//  String+Bon.swift
//  Bon
//
//  Created by Chris on 2019/5/16.
//  Copyright © 2019 Chris. All rights reserved.
//

import Foundation

extension String {
    
    func encodeURIComponent() -> String {
        var characterSet = CharacterSet.urlQueryAllowed
        characterSet.insert(charactersIn: "%-_.!~*'()")
        return self.addingPercentEncoding(withAllowedCharacters: characterSet)!
    }
    
    func encrypt() -> String {
        return UonRSA.encrypt(password: self)
    }
}
