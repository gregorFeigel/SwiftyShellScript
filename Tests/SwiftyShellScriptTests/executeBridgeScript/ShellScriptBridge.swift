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
    
    
    func testAdvancedFiles() {
        
        // let Script = ShellScripts().function("greet", param: "") // usage with bundle
        
        let Script = ShellScripts(mainDir).function("test", param: "")
        print(Script.processTime)
        print(Script.error)
        print(Script.exitState)
        print(Script.output)
        
//        let Script = ShellScripts(mainDir).test()
         
        
        
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




