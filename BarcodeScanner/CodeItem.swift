//
//  CodeItem.swift
//  BarcodeScanner
//
//  Created by Richard Shi on 1/9/17.
//  Copyright © 2017 Richard Shi. All rights reserved.
//

import Foundation

class CodeItem{
    
    var type:String
    var content:String
    var timestamp:Date
    
    init(content:String, type:String, timestamp:Date){
        self.type = content
        self.content = type
        self.timestamp = timestamp
    }
    
    convenience init(content:String, type:String){
        let currentDate = Date()
        self.init(content:content, type:type, timestamp:currentDate)
    }
}
