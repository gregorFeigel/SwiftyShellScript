//
//  File.swift
//  
//
//  Created by Gregor Feigel on 25.06.21.
//

import Foundation
import Darwin

import XCTest
@testable import SwiftyShellScript

/*

Please read the testMater.swift file

*/


final class executeHandlerTests: XCTestCase {
    
    
    func testShell() {
        
        let info = scriptInfo(path: "/Users/Gregor/Documents/XCTestSwiftyShellScript/testShell/Test.sh")
        _ = info.chmod(to: 755, .int)
        
        let tt = runScript(scriptPath: "/Users/Gregor/Documents/XCTestSwiftyShellScript/testShell/Test.sh") // "/Users/Gregor/Documents/XCTestSwiftyShellScript/testShell/Test.sh"
         tt.timeout = 5 //.infinity
//        let r = tt.shellPipe()
         tt.shellPrintRealTime()
        
        
        
//        print("\n")
//        print("output:\n" + r.output)
////        print("\n")
//        print("/* ------------------------------------------------- */")
//        print("\n")
//        print("error:\n" + r.error)
//        print("\n")
        
        
    }
    
    
    func testShellBool() {
        
        let info = scriptInfo(path: "/Users/Gregor/Documents/XCTestSwiftyShellScript/testShell/Test.sh")
        _ = info.chmod(to: 755, .int)
        
        let tt = runScript(scriptPath: "/Users/Gregor/Documents/XCTestSwiftyShellScript/testShell/Test.sh")
        tt.timeout = 20
        XCTAssertEqual(tt.shellBool(), false)
        
        let t = runScript(scriptPath: "ls -lrt")
        t.timeout = 20
        XCTAssertEqual(t.shellBool(), true)
        
    }
    
    
    
    func testQueue() {
        
//        let queue = runner(scriptPath: "")
//        queue.timeoutStop(5)
//        queue.task()
//        
//        sleep(10)
//        queue.stop()
        
    
        
    }
    


}
