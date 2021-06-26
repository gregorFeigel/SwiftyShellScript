//
//  File.swift
//
//
//  Created by Gregor Feigel on 24.06.21.
//

import Foundation

/*
 
 shell script renderer
 
 - get shell script content
 - replace variables- and custom tags with the input value
 - replace functions tags with the output of the user defined function - containing the function input - result
 
 */



public class shellScriptRenderer {
    
    
    public init(_ shellScriptPath: String) {
        self.shellScriptPath = shellScriptPath
    }
    
    var shellScriptPath : String
    var renderedShellScript = String()
    var renderedShellScriptPath = String()
    
    public var launchPath : String = "/bin/bash"
    public var arg : String = "-c"
    public var timeout : TimeInterval = 300 // intervall time in sec
    
    
    //MARK: - check if file already exists
    
    /// check if file already exists
    /// - Parameter t: file path as string e.g. /home/user/Documents/test.sh
    /// - Returns: true if file exits
    
    private func checkIfFileExits(_ t: String) -> Bool {
        
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: t) {
            return true
        } else {
            return false
        }
        
    }
    
    
    
    //MARK: - read file
    
    /// check if the file exists. if yes, get file content as string else return error message
    /// - Returns: file content as string and "the file \(shellScriptPath.self) does not exist" if the file does not exist
    
    func readFile() -> String {
        
        if checkIfFileExits(shellScriptPath.self) == true { return readFileAtDirection(path: shellScriptPath.self)  }
        else { return "the file \(shellScriptPath.self) does not exist" }
        
    }
    
    
    
    //MARK: - render file
    
    
    /* task type handler */
    
    ///  handle the task type and run the sub functions
    /// - Parameter t: struct of the item to replace with, the replacement value and the task type (custom, variable, function).
    
    public func render(_ t: [Item] ){
        
        var shellScript = readFile()
        
        for n in t {
            
            if n.taskType == .custom { shellScript = shellScript.removeAndReplaceString(items: [n.identifier], with: [n.input!]) }
            else if n.taskType == .function {  shellScript = function(i: n, script: shellScript)  }
            else if n.taskType == .variable {  shellScript = variable(i: n, script: shellScript)  }
            
        }
        
        renderedShellScript = shellScript
    }
    
    
    
    
    /* task type: variable */
    
    /// # find the variable identifier and replace it with the input content
    /// - Parameters:
    ///   - i: Item struct item - containing the identifier, function, task type and input
    ///   - script: shell script as string
    /// - Returns: rendered script as string
    
    private func variable(i: Item, script: String) -> String {
        
        var shellScript = script
        shellScript = shellScript.removeAndReplaceString(items: ["#(\(i.identifier))"], with: [i.input!])
        return shellScript
        
    }
    
    
    
    /* task type: function */
    
    /// # get the content of the function identifier, run the user function with the function identifier input and replace the function identifier + its input with the result
    /// # e.g.:
    /// # #getDate(yyyy-MM-dd HH:mm:ss) - find this function in the script
    /// # function input: yyyy-MM-dd HH:mm:ss - get the function input
    /// # execute the user function with the input "yyyy-MM-dd HH:mm:ss"
    /// # replace #getDate(yyyy-MM-dd HH:mm:ss) with 2021-06-24 17:22:27
    /// - Parameters:
    ///   - i: Item struct item - containing the identifier, function, task type and input
    ///   - script: shell script as string
    /// - Returns: rendered script as string
    
    private func function(i: Item, script: String) -> String {
        
        var shellScript = script
        
        if script.contains(i.identifier) {
            
            let input = script.getContentBetween(from: "#\(i.identifier)(", to: ")")
            
            shellScript = shellScript.replaceBetween(from: "#\(i.identifier)(", to: ")", by: "")
            
            let t = i.function!(input ?? "error")
            
            shellScript = shellScript.removeAndReplaceString(items: ["#\(i.identifier)()"], with: [t])
            
        } else {}
        
        return shellScript
        
    }
    
    
    
    
    //MARK: - export the file
    
    /// export the rendered file to export directory
    /// - Parameters:
    ///   - dir: export directory as string
    ///   - overwrite: select overwrite type [sensitive, force]
    /// - Returns: true if success - else false
    public func exportTo(_ dir: String, overwrite: overwrite = .sensitive) -> Bool {
        
        
        /* export if overwrite type == force */
        
        if overwrite == .force {
            
            let filename = URL(fileURLWithPath: dir)
            
            do {
                try renderedShellScript.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
                renderedShellScriptPath = dir
                return true
            } catch { return false }
            
        }
        
        
        /* export if overwrite type == sensitive */
        
        else if overwrite == .sensitive {
            
            if checkIfFileExits(dir) == true { return false } else {
                
                let filename = URL(fileURLWithPath: dir)
                
                do {
                    try renderedShellScript.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
                    renderedShellScriptPath = dir
                    return true
                } catch { return false }
                
            }
            
        }
        
        
        /* export if overwrite type is not set */ // this is basically not needed
        
        else {
            
            if checkIfFileExits(dir) == true { return false } else {
                
                let filename = URL(fileURLWithPath: dir)
                
                do {
                    try renderedShellScript.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
                    renderedShellScriptPath = dir
                    return true
                } catch { return false }
                
            }
            
        }
        
        
        
    }
    
    
    
    //MARK: -  change posix permissions
    
    /// change mod of file
    /// - Parameters:
    ///   - to: posixPermissions as int or as octal number
    ///   - t: number typ [octalNumber, int]
    /// - Returns: true if success - else false
    public func chmod(to: Int16, _ t: numberType) -> Bool {
        
        let fm = FileManager.default
        var number = Int16()
        
        
        /* get correct number format for setAttributes */
        
        if t == .int {
            
            // int to octal number
            let intToStr = "\(to)"
            let octal = Int(intToStr, radix: 8)
            number = Int16(octal!)
            
        }
        
        // if input == octal number just apply to number variable
        
        else if t == .octalNumber { number = to }
        
        
        /* change posixPermissions for file at renderedShellScriptPath */
        
        // check if file exists - else return false
        if checkIfFileExits(renderedShellScriptPath) {
            
            do {
                
                var attributes = [FileAttributeKey : Any]()
                attributes[.posixPermissions] = number // to
                
                try fm.setAttributes(attributes, ofItemAtPath: renderedShellScriptPath)
                
            } catch { return false  }
            
            return true
            
        } else { return false }
        
        
    }
    
    
    //MARK: - execute shell script
    
    @available(macOS 10.15, *)
    func runScript() -> (scriptOutput: String, scriptError: String, processTime: String, timeover: Bool, taskTerminationStatus: Int32 ,error: String) {
        
        let tmpFileName = "\(Date())--\(shellScriptPath)".asSHA256()
        var shellOutput = ("", "", "", false, Int32(110))
        let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(tmpFileName)
        // copy script to temp folder
        if writeTo(renderedShellScript, to: tmp) == true {
            if modify(tmp.path).chmod(to: 755, .int) == true {
                // run script
    
                shellOutput = mainShell(tmp.path, launchPath: launchPath, arg: arg, timeOut: timeout)
                
            } else { return (shellOutput.0, shellOutput.1, shellOutput.2, shellOutput.3, shellOutput.4, "error") }
                
        } else { return (shellOutput.0, shellOutput.1, shellOutput.2, shellOutput.3, shellOutput.4, "error") }
        
        // remove tmp file in tmp dir
//        print(tmp)
        _ = deleteAt(path: tmp.path)
        
        // return output
        
        return (shellOutput.0, shellOutput.1, shellOutput.2, shellOutput.3, shellOutput.4, "no error")
    }
    
    
    
    /* shell with timeout */

    private func mainShell(_ command: String, launchPath: String, arg: String, timeOut: TimeInterval) -> (output: String, error: String, duration: String, timoutInterupt: Bool, exitState: Int32) {
        
        let task = Process()
        let pipe = Pipe()
        let error = Pipe()
        
        var timeout = false
        var pTime = ""
        
        /* setup */
        
        task.standardOutput = pipe
        task.standardError = error
        task.arguments = [arg, command]
        task.launchPath = launchPath
        
        /* auto kill process if it takes to long */
        
        if timeOut == .infinity {} else {
             DispatchQueue.global().asyncAfter(deadline: .now() + timeOut) {
                 print("timeout !!!!!!")
                timeout = true
                task.terminate()
            
            }
        }
        
        let info = ProcessInfo.processInfo
        let begin = info.systemUptime
        
        task.launch()
        
        task.terminationHandler = { (process) in
             pTime = "\(info.systemUptime - begin)"
         }
        
        
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = error.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!
        let outputError = String(data: errorData, encoding: .utf8)!
        
        
        return (output, outputError, pTime, timeout, task.terminationStatus)
    }
    
    
}









//MARK: - enum and structs

public struct Item {
    
    public init(identifier: String, input: String? = "", function: ((String) -> String)? = nil, taskType: TaskType) {
        self.identifier = identifier
        self.input = input
        self.function = function
        self.taskType = taskType
    }
    
    public var identifier : String
    public var input : String?
    public var function: ((_ t: String)->String)?
    public var taskType : TaskType
    
    
}

public enum TaskType {
    
    case custom
    case variable
    case function
    
    
}

public enum overwrite {
    
    case sensitive
    case force
    
}

public enum numberType {
    case `int`
    case octalNumber
    
}







