//
//  File.swift
//
//  Licence: MIT
//  Created by Gregor Feigel on 25.06.21.
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
        XCTAssertNotNil(tt.type())
 
    }
    
    func testModify() {
        
        let tt = modify(txt)
        XCTAssertTrue(tt.chmod(to: 755, .int))
        XCTAssertTrue(tt.rename(to: "renamed.txt"))
        
        let file = modify(renamed)
        XCTAssertTrue(file.chmod(to: 0o644, .octalNumber))
        XCTAssertTrue(file.rename(to: "testFile.txt"))
        
        
    }
    
    func test_Modify() {
        
        // creation date
        let isoDate = "1960-04-14T10:44:00+0000"
        let isoDate2 = "3020-04-14T10:44:00+0000"

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let dd = dateFormatter.date(from:isoDate)!
        let ddd = dateFormatter.date(from:isoDate2)!

        
        // modify
        
         let ttt = modify(txt)
        
        XCTAssertTrue(ttt.modificationDate(to: ddd))
        XCTAssertTrue(ttt.creationDate(to: dd))
        
    }
    
    
    
    
    func testMDItem() {
        
        //kMDItemLastUsedDate
        let path = URL(fileURLWithPath: txt).path
        if let mditem = MDItemCreate(nil, path as CFString),
           let mdnames = MDItemCopyAttributeNames(mditem),
           let mdattrs = MDItemCopyAttributes(mditem, mdnames) as? [String:Any] {
            print(mdattrs)
            print("Creator: \(mdattrs[kMDItemCreator as String] as? String ?? "Unknown")")
        } else {
            print("Can't get attributes for \(path)")
        }
        
    }
    
    
    func testInvalidPath() {
        
        let tt = fileInfo("/notExisting")
        XCTAssertNil(tt.fileSize(.byte))
        
    }
    
}
