    import XCTest
    @testable import SwiftyShellScript
    
    final class SwiftyShellScriptTests: XCTestCase {
        
        
        
        let oriPath = getDocumentsDirectory().appendingPathComponent("Test.sh").path
        let exportPath = getDocumentsDirectory().appendingPathComponent("rTest.sh").path
        let correctRenderedScript = readFileAtDirection(path: getDocumentsDirectory().appendingPathComponent("cTest.sh").path)
        let correctScript = readFileAtDirection(path: getDocumentsDirectory().appendingPathComponent("Test.sh").path)
        
        
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
            
            let info = scriptInfo(path: exportPath)
            XCTAssertEqual(info.getPosixPermissions(as: .int), 555)

            
        }
        
        
        
        /* wrong input path */
        
        func testFalsePath() {
            
            let a = Item(identifier: "test", input: "everything worked!", taskType: .variable)
            
            let b = Item(identifier: "getDate", function: { r in r.getDate() }, taskType: .function)
            
            let c = Item(identifier: "§§hi", input: "this is a custom tag", taskType: .custom)
            
            let Array = [a, b, c]
            
            let script = shellScriptRenderer(oriPath)
            XCTAssertEqual(script.readFile(), correctScript)
            script.render(Array)
            XCTAssertEqual(script.renderedShellScript, correctRenderedScript)
            XCTAssertEqual(script.exportTo(exportPath, overwrite: .force), true)
            XCTAssertEqual(script.chmod(to: 755, .int), true)
            
        }
        
        
        
        /* empty function */
        
        func testEmptyFunctionInput() {
            
            let a = Item(identifier: "test", input: "everything worked!", taskType: .variable)
            
            let b = Item(identifier: "getDate", function: { r in r.getDate() }, taskType: .function)
            
            let c = Item(identifier: "§§hi", input: "this is a custom tag", taskType: .custom)
            
            let Array = [a, b, c]
            
            let script = shellScriptRenderer(oriPath)
            XCTAssertEqual(script.readFile(), correctScript)
            script.render(Array)
            XCTAssertEqual(script.renderedShellScript, correctRenderedScript)
            XCTAssertEqual(script.exportTo(exportPath, overwrite: .force), true)
            XCTAssertEqual(script.chmod(to: 755, .int), true)
            
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
    
