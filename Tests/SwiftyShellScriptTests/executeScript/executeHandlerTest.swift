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


final class executeHandlerTests: XCTestCase {
    
    let script = dir(withPath: "/testScript/Test1.sh")
    let script20 = dir(withPath: "/testScript/Test20.sh")
    let scriptError = dir(withPath: "/testScript/TestError.sh")
    
    let scriptTrue = dir(withPath: "/testScript/TestTrue.sh")
    let scriptFalse = dir(withPath: "/testScript/TestFalse.sh")
    
    
    /* make all scripts executable */
    
    func testMakeScriptExecutable() {
        
        XCTAssertEqual(modify(script).chmod(to: 755, .int), true)
        XCTAssertEqual(modify(script20).chmod(to: 755, .int), true)
        XCTAssertEqual(modify(scriptError).chmod(to: 755, .int), true)
        XCTAssertEqual(modify(scriptTrue).chmod(to: 755, .int), true)
        XCTAssertEqual(modify(scriptFalse).chmod(to: 755, .int), true)
        
    }
    
    
    func testRealTimeShell() {
         
         let script = runScript(scriptPath: script20)
         script.timeout = 5
         script.shellPrintRealTime()
     
         /* run without timeout */
     
         let script1 = runScript(scriptPath: script20)
         script1.timeout = 30
         script1.shellPrintRealTime()
         
     }
    
    
    func testScript() {
        
        let script = runScript(scriptPath: script)
        script.timeout = 5
        let output = script.runDefault()
        
        XCTAssertEqual(output.timeoutInterrupt, false)
        XCTAssertEqual(output.error, "")
        XCTAssertEqual(output.standardOutput, "This is a test\n")
        XCTAssertEqual(output.standardError, "")
        XCTAssertEqual(output.terminationStatus, 0)
        
        
    }
    
    
    func testScript20() {
        
        /* run with interrupt 5 sec  */
        
        let script = runScript(scriptPath: script20)
        script.timeout = 5
        let output = script.runDefault()
        
        XCTAssertEqual(output.timeoutInterrupt, true)
        XCTAssertEqual(output.error, "")
        XCTAssertEqual(output.standardOutput, "Hi\n")
        XCTAssertEqual(output.standardError, "")
        XCTAssertEqual(output.terminationStatus, 15)
        XCTAssertEqual(output.processTime.rounded(), 5)

    }
    
    func testScript20Timeout15() {
        
        /* run with interrupt 15 sec  */
        
        let script1 = runScript(scriptPath: script20)
        script1.timeout = 15
        let output1 = script1.runDefault()
        
        print(output1.processTime.rounded())
        
        XCTAssertEqual(output1.timeoutInterrupt, true)
        XCTAssertEqual(output1.error, "")
        XCTAssertEqual(output1.standardOutput, "Hi\n")
        XCTAssertEqual(output1.standardError, "")
        XCTAssertEqual(output1.terminationStatus, 15)
        XCTAssertEqual(output1.processTime.rounded(), 15)
        
    }
    
    func testScript20NoTimeout() {
        
        /* run with no interrupt 30 sec  */ // script should take max 20 sec to finish
        
        let script2 = runScript(scriptPath: script20)
        script2.timeout = 30
        let output2 = script2.runDefault()
        
        print(output2.processTime.rounded())
        
        XCTAssertEqual(output2.timeoutInterrupt, false)
        XCTAssertEqual(output2.error, "")
        XCTAssertEqual(output2.standardOutput, "Hi\nend\n")
        XCTAssertEqual(output2.standardError, "")
        XCTAssertEqual(output2.terminationStatus, 0)
        XCTAssertEqual(output2.processTime.rounded(), 20)
        
        
    }
    
    
    func testScriptError() {
        
        let script = runScript(scriptPath: scriptError)
        script.timeout = 10
        let output = script.runDefault()
        
        XCTAssertEqual(output.timeoutInterrupt, false)
        XCTAssertEqual(output.error, "")
        XCTAssertEqual(output.standardOutput, "This is a test\n")
        XCTAssertEqual(output.standardError, "ls: /home/doesNotExist: No such file or directory\n")
        XCTAssertEqual(output.terminationStatus, 0)
        
        /* run script with -e flag */
        
        let script1 = runScript(scriptPath: scriptError)
        script1.timeout = 10
        script1.arg = "-e"
        let output1 = script1.runDefault()
        
        XCTAssertEqual(output1.timeoutInterrupt, false)
        XCTAssertEqual(output1.error, "")
        XCTAssertEqual(output1.standardOutput, "")
        XCTAssertEqual(output1.standardError, "ls: /home/doesNotExist: No such file or directory\n")
        XCTAssertEqual(output1.terminationStatus, 1)
        
        
    }
 
    
    
    func testShellBool() {
    
        
        let script = runScript(scriptPath: scriptTrue)
        script.timeout = 20
        XCTAssertEqual(script.shellBool(), true)
        
        let script1 = runScript(scriptPath: scriptFalse)
        script1.timeout = 20
        XCTAssertEqual(script1.shellBool(), false)
        
        
        let script2 = runScript(scriptPath: "ls -lrt")
        script2.timeout = 20
        XCTAssertEqual(script2.shellBool(), true)
        
    }
    
    
    func testErrorOutputScript() {
        
        let script0 = runScript(scriptPath: scriptError)
        XCTAssertEqual(script0.shellErrorsOnly(), "ls: /home/doesNotExist: No such file or directory\n")
        
        let script1 = runScript(scriptPath: script)
        XCTAssertEqual(script1.shellErrorsOnly(), "")
        
    }
    
    
 
    


}
