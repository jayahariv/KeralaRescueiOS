//
/*
HowToPrepareModel.swift
Created on: 2/9/18

Abstract:
 this will represent the data which is returned from the server.

*/

import Foundation


final class HowToPrepareModel: NSObject {
    var index: String?
    var content: String?
    
    required init(_ id: String, info: String) {
        super.init()
        index = id
        content = info
    }
}
