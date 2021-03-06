//
//  File.swift
//
//  Licence: MIT
//  Created by Gregor Feigel on 25.06.21.
//

  import XCTest
    @testable import SwiftyShellScript
    
    /*
    
   Please read the testMater.swift file 
    
    */
    
    
    final class SwiftyShellScriptTests: XCTestCase {
        
        let testExec = dir(withPath: "/TestEX.sh")
        
        let oriPath = dir(withPath: "/Test.sh")
        let exportPath = dir(withPath: "/rTest.sh")
        let correctRenderedScript = readFileAtDirection(path: dir(withPath: "/cTest.sh"))
        let correctScript = readFileAtDirection(path: dir(withPath: "/Test.sh"))
        
        
        /* everything should work here */
        
        func testShell() {
            
            let a = Item(identifier: "test", input: "everything worked!", taskType: .variable)
            
            let b = Item(identifier: "getDate", function: { r in r.getDate() }, taskType: .function)
            
            let c = Item(identifier: "§§hi", input: "this is a custom tag", taskType: .custom)
            
            let Array = [a, b, c]
            
            let script = shellScriptRenderer(oriPath)
            XCTAssertEqual(script.readFile(), correctScript)
            script.render(Array)
            XCTAssertEqual(script.renderedShellScript, correctRenderedScript)
            XCTAssertEqual(script.exportTo(exportPath, overwrite: .force), true)
            XCTAssertEqual(script.chmod(to: 555, .int), true)
            
            // check if posix permissions where changed correctly
            
             XCTAssertEqual(fileInfo(exportPath).posixPermissions(as: .int), 555)

            
        }
        
        
        
        func testAndExecute() {
            
            let a = Item(identifier: "test", input: "#everything worked!", taskType: .variable)
            
            let script = shellScriptRenderer(testExec)
            script.timeout = 3
            script.render([a])
            let t = script.runScript()
            
            print(t.processTime)
            print(t.timeoutInterrupt)
            print(t.error)
            print(t.terminationStatus)
            print(t.standardError)
            print(t.standardOutput)
            
        }
        
        
    }
    
    
    
    
    

    
    extension String {
        
        func s() -> String {
            
            
            let formatted = Date().getFormattedDate(format: self)
            var tt = ""
            for n in 1...5 { tt = tt + "\(n): \(self.count) -> " + formatted  + "\n"}
            
            return tt
        }
        
    }
    
    extension Date {
        func getFormattedDate(format: String) -> String {
            let dateformat = DateFormatter()
            dateformat.dateFormat = format
            return dateformat.string(from: self)
        }
    }
    
    
    extension String {
        
        func getDate() -> String {
            
//            let dateFormat = DateFormatter()
//            dateFormat.dateFormat = self
//            return dateFormat.string(from: Date()) + "the input format was:" + self
        
            var output = ""
            for n in 0...10 { output.append("\(n): - the input format was: " + self + "\n") }
            return output
            
        }
        
    }
    
    

