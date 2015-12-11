//
//  Product.swift
//  GuanJia
//
//  Created by Liang Sun on 12/11/15.
//  Copyright © 2015 Lyon Sun. All rights reserved.
//

import UIKit

class Product: NSObject {
    
    // MARK: Properties
    var name: String
    var desc: String
    
    // MARK Initialization
    init?(name: String, desc: String) {
        self.name = name
        self.desc = desc
        
        super.init()
    }
}
