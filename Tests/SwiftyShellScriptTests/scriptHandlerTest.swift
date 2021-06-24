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
    
    let txt = dir(withPath: "/multiFileTypes/testFile.txt")
    let large = dir(withPath: "/multiFileTypes/largeFile.txt")
    let data = dir(withPath: "/multiFileTypes/testFile.data")
    let pdf = dir(withPath: "/multiFileTypes/testFile.pdf")
    let swift = dir(withPath: "/multiFileTypes/testFile.swift")
    let shell = dir(withPath: "/multiFileTypes/testFile.sh")
    let notExistingFile = dir(withPath: "/multiFileTypes/notExisting.txt")
    let folder = dir(withPath: "/multiFileTypes")
    
    /* test each function itself */
    
    func testIfFileExists() {
        let info = scriptInfo(path: txt)
        XCTAssertEqual(info.checkIfFileExits(), true)
        
    }
    
    func testIfFileExistsWithWrongPath() {
        let info = scriptInfo(path: notExistingFile)
        XCTAssertEqual(info.checkIfFileExits(), false)
        
    }
    
    func testFilePermissions() {
        
        let info = scriptInfo(path: txt)
        XCTAssertEqual(info.getPosixPermissions(as: .int), 644)
        
    }
    
    
    func testFileSize() {
        
        let info = scriptInfo(path: txt)
        XCTAssertEqual(info.getFileSize(.byte), 18.0)
        
    }
    
    
    func testFileOwner() {
        
        let info = scriptInfo(path: txt)
        XCTAssertEqual(info.getGroupOwnerAccountName(), "staff")
        
    }
    
    
    func testFileType() {
        
        let info = scriptInfo(path: txt)
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
    
    //MARK: - test different files
    
    
    /* test different cases */
    
    func testLargeFile() {
        
        let info = scriptInfo(path: large)
        XCTAssertEqual(info.getFileType(), "NSFileTypeRegular")
        XCTAssertEqual(info.getGroupOwnerAccountName(), "staff")
        XCTAssertEqual(info.getPosixPermissions(as: .int), 644)
        XCTAssertEqual(info.checkIfFileExits(), true)
        
        XCTAssertEqual(info.getFileSize(.byte), 10811414.0)
        XCTAssertEqual(info.getFileSize(.kiloByte), 10811.0)
        XCTAssertEqual(info.getFileSize(.megaByte), 10.811)
        XCTAssertEqual(info.getFileSize(.gigaByte), 0.010811)
        
    }
    
    func testDateFile() {
        
        let info = scriptInfo(path: data)
        XCTAssertEqual(info.getFileType(), "NSFileTypeRegular")
        XCTAssertEqual(info.getGroupOwnerAccountName(), "staff")
        XCTAssertEqual(info.getPosixPermissions(as: .int), 644)
        XCTAssertEqual(info.checkIfFileExits(), true)
        XCTAssertEqual(info.getFileSize(.byte), 19.0)
        
    }
    
    func testPdfFile() {
        
        let info = scriptInfo(path: pdf)
        XCTAssertEqual(info.getFileType(), "NSFileTypeRegular")
        XCTAssertEqual(info.getGroupOwnerAccountName(), "staff")
        XCTAssertEqual(info.getPosixPermissions(as: .int), 644)
        XCTAssertEqual(info.checkIfFileExits(), true)
        XCTAssertEqual(info.getFileSize(.byte), 12017.0)
        
    }
    
    func testSwiftFile() {
        
        let info = scriptInfo(path: swift)
        XCTAssertEqual(info.getFileType(), "NSFileTypeRegular")
        XCTAssertEqual(info.getGroupOwnerAccountName(), "staff")
        XCTAssertEqual(info.getPosixPermissions(as: .int), 644)
        XCTAssertEqual(info.checkIfFileExits(), true)
        XCTAssertEqual(info.getFileSize(.byte), 18.0)
        
    }
    
    func testShellFile() {
        
        let info = scriptInfo(path: shell)
        XCTAssertEqual(info.getFileType(), "NSFileTypeRegular")
        XCTAssertEqual(info.getGroupOwnerAccountName(), "staff")
        XCTAssertEqual(info.getPosixPermissions(as: .int), 644)
        XCTAssertEqual(info.checkIfFileExits(), true)
        XCTAssertEqual(info.getFileSize(.byte), 18.0)
        
    }
    
    
    func testFolder() {
        
        let info = scriptInfo(path: folder)
        XCTAssertEqual(info.getFileType(), "NSFileTypeDirectory")
        XCTAssertEqual(info.getGroupOwnerAccountName(), "staff")
        XCTAssertEqual(info.getPosixPermissions(as: .int), 755)
        XCTAssertEqual(info.checkIfFileExits(), true)
        XCTAssertEqual(info.getFileSize(.byte), 288.0)
        
    }
    
    
    //MARK: - check modifier options
    
    
    func testChmod() {
        
        /* using int as input type */
        
        let info = scriptInfo(path: shell)
        XCTAssertEqual(info.chmod(to: 755, .int), true)
        XCTAssertEqual(info.getPosixPermissions(as: .int), 755)
        
        XCTAssertEqual(info.chmod(to: 333, .int), true)
        XCTAssertEqual(info.getPosixPermissions(as: .int), 333)
        
        XCTAssertEqual(info.chmod(to: 644, .int), true)
        XCTAssertEqual(info.getPosixPermissions(as: .int), 644)
        
        
        
        /* using octal as input type */
        
        XCTAssertEqual(info.chmod(to: 0o755, .octalNumber), true)
        XCTAssertEqual(info.getPosixPermissions(as: .int), 755)
        
        XCTAssertEqual(info.chmod(to: 0o333, .octalNumber), true)
        XCTAssertEqual(info.getPosixPermissions(as: .int), 333)
        
        XCTAssertEqual(info.chmod(to: 0o644, .octalNumber), true)
        XCTAssertEqual(info.getPosixPermissions(as: .int), 644)
        
        
        /* using octal as input type and as output */
        
        XCTAssertEqual(info.chmod(to: 0o755, .octalNumber), true)
        XCTAssertEqual(info.getPosixPermissions(as: .octalNumber), 0o755)
        
        XCTAssertEqual(info.chmod(to: 0o333, .octalNumber), true)
        XCTAssertEqual(info.getPosixPermissions(as: .octalNumber), 0o333)
        
        XCTAssertEqual(info.chmod(to: 0o644, .octalNumber), true)
        XCTAssertEqual(info.getPosixPermissions(as: .octalNumber), 0o644)
        
        
    }
    
    
    
    
    
    
    
    
}


func getDate(from: String) -> Date {
    
    
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_DE_POSIX") // set locale to reliable US_POSIX
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
    return dateFormatter.date(from: from)!
    
}
