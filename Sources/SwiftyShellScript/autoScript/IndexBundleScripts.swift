//
//  File.swift
//  
//
//  Created by Gregor Feigel on 25.06.21.
//

/*
 
 - check if bundle contains a "shellScript" folder and get all scripts from there
 - index all scripts
 
 */

/*
 
 Bridge header:
 
 # /* SwiftyShellScript Bridge
 #
 # - function: functionName A
 # - function: functionName B
 #
 #
 # */End
 
 */


/* in progress */

import Foundation

public class ShellScripts {
    
    
    public init(_ path: URL? = Bundle.main.resourceURL?.appendingPathComponent("/shellScripts")) { //, location: location? = .bundle
        self.path = path
        //        self.location = location
        self.initScripts = index(getAllScripts())
    }
    
    
    var path: URL?
    //    var location: location?
    public var launchPath : String = "/bin/bash"
    public var arg : String = "-c"
    public var timeout : TimeInterval = 300 // intervall time in sec
    
    //MARK: - run function
    
    var initScripts : [shellScript] = []  //[]
    
    public func function(_ t: String, param: String, timeout: TimeInterval? = 300) -> shellOutput {
        
        // get the script that the function contains
        var scriptPath = ""
        
        let index = initScripts.firstIndex(where: { $0.functions.contains(t)})
        scriptPath = initScripts[index!].scriptName
        
        print(scriptPath)
        
        _ = modify(scriptPath).chmod(to: 755, .int)
         
        let shell = mainShell(scriptPath + " " + t + " " + param, launchPath: launchPath, arg: arg, timeOut: timeout!)
        
        
        return shellOutput(standardOutput: shell.output, standardError: shell.error, processTime: shell.duration, timeoutInterrupt: shell.timeoutInterrupt, terminationStatus: shell.exitState, error: "")
    }
    
    
    
    //MARK: - test func
    
    public func  test() {
        
        let t = index(getAllScripts())
        
        for n in t {
            
            print(n)
        }
        
    }
    
    
    //MARK: - get all shell scripts from bundle
    
    private func getAllScripts() -> [String] {
        
        let shellScriptFolder = path
        var allShellScripts = [String]()
        
        if checkIfFileExits(shellScriptFolder!.path) == false { print("no such folder") } else {
            
            do {
                let resourceKeys : [URLResourceKey] = [.creationDateKey, .isDirectoryKey]
                let enumerator = FileManager.default.enumerator(at: shellScriptFolder!,
                                                                includingPropertiesForKeys: resourceKeys,
                                                                options: [.skipsHiddenFiles], errorHandler: { (url, error) -> Bool in
                                                                    return true
                                                                })!
                
                for case let fileURL as URL in enumerator {
                    let resourceValues = try fileURL.resourceValues(forKeys: Set(resourceKeys))
                    //                print(fileURL.path, resourceValues.creationDate!, resourceValues.isDirectory!)
                    if resourceValues.isDirectory! == true || fileURL.pathExtension != "sh" {}
                    else {
                        allShellScripts.append(fileURL.path)
                    }
                    
                }
            } catch {
                print(error)
            }
            
        }
        return allShellScripts
        
    }
    
    
    //MARK: - index files
    
    private func index(_ t: [String]) -> [shellScript] {
        
        var allIndexedFiles : [shellScript] = []
        
        for n in t {
            allIndexedFiles.append(indexFile(n))
        }
        
        return allIndexedFiles
    }
    
    
    
    private func indexFile(_ t: String) -> shellScript {
        
        let bridgeHeaderStart = "# /* SwiftyShellScript Bridge"
        let bridgeHeaderEnd = "# */End"
        let script = readFileAtDirection(path: t)
        let bridgeContent = script.getContentBetween(from: bridgeHeaderStart, to: bridgeHeaderEnd) ?? "error"
        var array = bridgeContent.components(separatedBy: "\n")
        array.removeAllEmptyItemsFromArray()
        array.removeAllFromArray(txt: " ")
        
        var functions = [String]()
        
        for n in array {
            
            if n.contains("- function:") {
                
                var array = n.components(separatedBy: ":")
                array.removeAllEmptyItemsFromArray()
                functions.append(array[1].remove(items: [" ", "\t"]))
            }
            
        }
        
        
        
        return shellScript(scriptName: t, functions: functions)
    }
    
    
    
    
    
    
    private func checkIfFileExits(_ t: String) -> Bool {
        
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: t) {
            return true
        } else {
            return false
        }
        
    }
    
    /* shell with timeout */

    private func mainShell(_ command: String, launchPath: String, arg: String, timeOut: TimeInterval) -> (output: String, error: String, duration: Double, timeoutInterrupt: Bool, exitState: Int32) {
        
        let task = Process()
        let pipe = Pipe()
        let error = Pipe()
        
        var timeout = false
        var pTime = Double()
        
        /* setup */
        
        task.standardOutput = pipe
        task.standardError = error
        task.arguments = [arg, command]
        if #available(macOS 10.13, *) {
            task.executableURL = URL(fileURLWithPath: launchPath)
        } else {
            task.launchPath = launchPath
        }
        
        /* auto kill process if it takes to long */
        
        let info = ProcessInfo.processInfo
        let begin = info.systemUptime
        
        task.launch()
        
        if timeOut == .infinity {} else {
            
//             DispatchQueue.global().asyncAfter(deadline: .now() + timeOut) {
//                 print("timeout !!!!!!")
//                timeout = true
//                task.terminate()
//
//            }
            
            
            
            DispatchQueue.global(qos: .background).async {
                
                while task.isRunning == true {
                    
                    if info.systemUptime - begin <= timeOut { }
                    else {
                        usleep(250000) // 1000000 1.000.000
                        task.terminate()
                        print("timeout !!!!!!")
                        timeout = true
                        
                    }
                    
                }
             
            }
            
        }
    
        task.terminationHandler = { (process) in
             pTime = info.systemUptime - begin
         }
        
        
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = error.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!
        let outputError = String(data: errorData, encoding: .utf8)!
        
        
        return (output, outputError, pTime, timeout, task.terminationStatus)
    }
    
}

public enum location {
    case bundle
    case custom
    
}

struct shellScript {
    
    var scriptName: String
    var functions: [String]
    
    
}
