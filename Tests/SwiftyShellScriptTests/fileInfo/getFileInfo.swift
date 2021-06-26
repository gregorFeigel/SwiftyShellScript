//
//  File.swift
//  
//
//  Created by Admin on 26.06.21.
//

import Foundation
 
import Darwin

import XCTest
@testable import SwiftyShellScript


/*

Please read the testMater.swift file

*/


final class testFileInfo: XCTestCase {
    
    let txt = dir(withPath: "/multiFileTypes/testFile.txt")
    let large = dir(withPath: "/multiFileTypes/largeFile.txt")
    let data = dir(withPath: "/multiFileTypes/testFile.data")
    let pdf = dir(withPath: "/multiFileTypes/testFile.pdf")
    let swift = dir(withPath: "/multiFileTypes/testFile.swift")
    let shell = dir(withPath: "/multiFileTypes/testFile.sh")
    let notExistingFile = dir(withPath: "/multiFileTypes/notExisting.txt")
    let folder = dir(withPath: "/multiFileTypes")
    
    
    func testGetInfo() {
        
        let tt = fileInfo(txt)
        print(tt.fileSize(.byte)!)
        print(tt.groupOwnerAccountName()!)
        print(tt.ownerAccountName()!)
        print(tt.posixPermissions(as: .octalNumber)!)
        
        // resource values
        
        print(tt.isExecutableKey()!)
        print(tt.isReadableKey()!)
        print(tt.isWritableKey()!)
        print(tt.isSymbolicLinkKey()!)
        
        
    }
    
}
