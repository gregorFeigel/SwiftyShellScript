//
//  File.swift
//  
//
//  Created by Gregor Feigel on 24.06.21.
//

import XCTest
@testable import SwiftyShellScript

 /*
 
 For testing download the testing files and move them into Documents/
 
 */

final class scriptHandler: XCTestCase {
    
    let oriPath = getDocumentsDirectory().appendingPathComponent("Test.sh").path
    let exportPath = getDocumentsDirectory().appendingPathComponent("rTest.sh").path
    let correctRenderedScript = readFileAtDirection(path: getDocumentsDirectory().appendingPathComponent("cTest.sh").path)
    let correctScript = readFileAtDirection(path: getDocumentsDirectory().appendingPathComponent("Test.sh").path)
    
    
    func testFilePermissions() {
        
        let info = scriptInfo(path: exportPath)
        XCTAssertEqual(info.getPosixPermissions(as: .int), 555)
        
    }
    
    
    func testFileSize() {
        
        let info = scriptInfo(path: exportPath)
        XCTAssertEqual(info.getFileSize(.byte), 587)
        
    }
    
    
    func testFileOwner() {
        
        let info = scriptInfo(path: exportPath)
        XCTAssertEqual(info.getGroupOwnerAccountName(), "staff")
        
    }
    
    
    func testFileType() {
        
        let info = scriptInfo(path: exportPath)
        XCTAssertEqual(info.getFileType(), "NSFileTypeRegular")
        
    }
    
    // FIXME: - error comparing two dates
    
//    func testFileCreationDate() {
//        let info = scriptInfo(path: exportPath)
//        XCTAssertEqual(info.getCreationDate(), getDate(from: "2021-06-24 17:41:15+0000")) //"2016-04-14T10:44:00+0000"
//    }
//
    // FIXME: - error comparing two dates
    
//    func testFileModificationDate() {
//        let info = scriptInfo(path: exportPath)
//        XCTAssertEqual(info.getModificationDate(), getDate(from: "2021-06-24 17:41:15+0000")) //"2016-04-14T10:44:00+0000"
//    }
//
//
    
}


func getDate(from: String) -> Date {
    
    
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_DE_POSIX") // set locale to reliable US_POSIX
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
    return dateFormatter.date(from: from)!
    
}
