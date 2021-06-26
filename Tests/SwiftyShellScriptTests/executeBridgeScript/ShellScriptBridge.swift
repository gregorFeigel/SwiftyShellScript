//
//  File.swift
//  
//
//  Created by Gregor Feigel on 25.06.21.
//

import Foundation
import XCTest
@testable import SwiftyShellScript

/*
 
 For testing download the testing files and move them into Documents/
 
 */

final class shellBridge: XCTestCase {
    
    let mainDir = URL(fileURLWithPath: dir(withPath: ""))
    
    
    func testRunFunction() {
        
        // let Script = ShellScripts().function("greet", param: "") // usage with bundle
        
        let Script = ShellScripts(mainDir).function("test", param: "")
        
        print(Script.processTime)
 
        XCTAssertEqual(Script.standardOutput, "Hi\n")
        XCTAssertEqual(Script.standardError, "")
        XCTAssertEqual(Script.terminationStatus, 0)
        XCTAssertEqual(Script.timeoutInterrupt, false)
  
    }
    
    
    func testRunFunctionWithTimeout() {
        
        let Script = ShellScripts(mainDir).function("test", param: "", timeout: 3)
        
        print(Script.processTime)
 
        XCTAssertEqual(Script.standardOutput, "")
        XCTAssertEqual(Script.standardError, "")
        XCTAssertEqual(Script.terminationStatus, 15)
        XCTAssertEqual(Script.timeoutInterrupt, true)
        XCTAssertEqual(Script.processTime.rounded(), 3)
        
    }
    
    
    func testRunFunctionWithError() {
        
        let Script = ShellScripts(mainDir).function("notWorking", param: "", timeout: 30)
        
        print(Script.processTime)
 
        XCTAssertEqual(Script.standardOutput, "Hi\n")
        XCTAssertEqual(Script.standardError, "ls: /home/notExisting: No such file or directory\n")
        XCTAssertEqual(Script.terminationStatus, 0)
        XCTAssertEqual(Script.timeoutInterrupt, false)
        
    }
    
    
    
}





private func checkIfFileExits(_ t: String) -> Bool {
    
    let fileManager = FileManager.default
    if fileManager.fileExists(atPath: t) {
        return true
    } else {
        return false
    }
    
}





