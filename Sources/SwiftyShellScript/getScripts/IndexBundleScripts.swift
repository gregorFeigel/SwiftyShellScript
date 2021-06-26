//
//  File.swift
//  
//
//  Created by Gregor Feigel on 25.06.21.
//

import Foundation

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


public class ShellScripts {
    
    
    public init(_ path: URL? = Bundle.main.resourceURL?.appendingPathComponent("/shellScript")) { //, location: location? = .bundle
        self.path = path
//        self.location = location
        self.initScripts = index(getAllScripts())
    }
    
    
    var path: URL?
//    var location: location?
    
    //MARK: - run function
    
    var initScripts : [shellScript] = []  //[]
    
    public func function(_ t: String, param: String, timeout: TimeInterval? = 300) -> (output: String, error: String) {
 
        // get the script that the function contains
        var scriptPath = ""
        
        let index = initScripts.firstIndex(where: { $0.functions.contains(t)})
        scriptPath = initScripts[index!].scriptName
        
        print(scriptPath)
        
        let shell = runScript(scriptPath: scriptPath + " " + t + "" + param )
        shell.timeout = timeout!
        let execute = shell.shellPipe()
        
        
        return (execute.output, execute.error)
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
                                                                    print("directoryEnumerator error at \(url): ", error)
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
    
}

public enum location {
    case bundle
    case custom
    
}

struct shellScript {
    
    var scriptName: String
    var functions: [String]
    
    
}
