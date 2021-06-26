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
    let renamed = dir(withPath: "/multiFileTypes/renamed.txt")
    let large = dir(withPath: "/multiFileTypes/largeFile.txt")
    let data = dir(withPath: "/multiFileTypes/testFile.data")
    let pdf = dir(withPath: "/multiFileTypes/testFile.pdf")
    let swift = dir(withPath: "/multiFileTypes/testFile.swift")
    let shell = dir(withPath: "/multiFileTypes/testFile.sh")
    let notExistingFile = dir(withPath: "/multiFileTypes/notExisting.txt")
    let folder = dir(withPath: "/multiFileTypes")
    
    
    func testGetInfo() {
        
        let tt = fileInfo(txt)
        XCTAssertNotNil(tt.fileSize(.byte))
        XCTAssertNotNil(tt.groupOwnerAccountName())
        XCTAssertNotNil(tt.ownerAccountName())
        XCTAssertNotNil(tt.posixPermissions(as: .octalNumber))
        XCTAssertNotNil(tt.posixPermissions(as: .int))
        
        /* resource values*/
        
        XCTAssertNotNil(tt.isExecutable() )
        XCTAssertNotNil(tt.isReadable())
        XCTAssertNotNil(tt.isWritable())
        XCTAssertNotNil(tt.isSymbolicLink())
        
        
    }
    
    func testModify() {
        
        let tt = modify(txt)
        XCTAssertTrue(tt.chmod(to: 755, .int))
        XCTAssertTrue(tt.rename(to: "renamed.txt"))
        
        let file = modify(renamed)
        XCTAssertTrue(file.chmod(to: 0o644, .octalNumber))
        XCTAssertTrue(file.rename(to: "testFile.txt"))
        
        
    }
    
    func testInvalidPath() {
        
        let tt = fileInfo("/notExisting")
        XCTAssertNil(tt.fileSize(.byte))
        
    }
    
}
