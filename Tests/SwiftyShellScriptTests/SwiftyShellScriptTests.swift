    import XCTest
    @testable import SwiftyShellScript
    
    final class SwiftyShellScriptTests: XCTestCase {
        
        func testShell() {
            
            let a = Item(identifier: "test", input: "everything here!", taskType: .variable)
            
            let b = Item(identifier: "date", function: { r in r.s() }, taskType: .function)
            
            let c = Item(identifier: "xc", input: "444", taskType: .custom)
            
            let Array = [a, b, c]
                        
            let script = shellScriptRenderer("/Users/Gregor/Documents/Test.sh")
            script.render(Array)
            _ = script.exportTo("/Users/Gregor/Documents/cTest.sh", overwrite: .force)
            
            XCTAssertEqual(script.chmod(to: 755, .int), true)
        }
        
        
    }
    
    @discardableResult
    func shell(_ args: String...) -> String {
        let task = Process()
        let pipe = Pipe()
        task.launchPath = "/bin/bash/"
        task.arguments = args
        task.launch()
        task.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!
        return output
    }
 
    
    extension String {
        
         func s() -> String {
            
            
            let formatted = Date().getFormattedDate(format: self)
            var tt = ""
            for n in 1...7 { tt = tt + "\(n): \(self.count) -> " + formatted  + "\n"}
            
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
            
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = self
            return dateFormat.string(from: Date()) + "the input format was:" + self
            
        }
        
    }
    
    
