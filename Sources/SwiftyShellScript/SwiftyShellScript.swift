import Foundation

public class shellScriptRenderer {
    
    
    public init(_ shellScriptPath: String) {
        self.shellScriptPath = shellScriptPath
    }
    
    var shellScriptPath : String
    var renderedShellScript = String()
    var renderedShellScriptPath = String()
    
    
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
    
    private func readFile() -> String {
        
        if checkIfFileExits(shellScriptPath.self) == true { return readFileAtDirection(path: shellScriptPath.self)  }
        else { return "the file \(shellScriptPath.self) does not exist" }
        
    }
    
    
    
    //MARK: - render file
    
    
    ///  render the script
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
    
    
    
    private func variable(i: Item, script: String) -> String {
        
        var shellScript = script
        shellScript = shellScript.removeAndReplaceString(items: ["#(\(i.identifier))"], with: [i.input!])
        return shellScript
        
    }
    
    
    
    
    
    private func function(i: Item, script: String) -> String {
        
        var shellScript = script
        
        if script.contains(i.identifier) {
            
            let input = script.getContentBetween(from: "#\(i.identifier)(", to: ")")
            
            shellScript = shellScript.replaced(from: "#\(i.identifier)(", to: ")", by: "")
            
            let t = i.function!(input ?? "error")
            
            shellScript = shellScript.removeAndReplaceString(items: ["#\(i.identifier)()"], with: [t])
            
        } else {}
        
        
        return shellScript
        
    }
    
    
    
    
    //MARK: - export the file
    public func exportTo(_ dir: String, overwrite: overwrite = .sensitive) -> Bool {
        
        
        
        if overwrite == .force {
            
            let filename = URL(fileURLWithPath: dir)
            
            do {
                try renderedShellScript.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
                renderedShellScriptPath = dir
                return true
            } catch { return false }
            
        }
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
    
    
    public func chmod(to: Int16, _ t: numberType) -> Bool {
        
        var number = Int16()
        
        if t == .int {
            
            let decimal = 755
            let intToStr = "\(decimal)"
            let octal = Int(intToStr, radix: 8)
            number = Int16(octal!)
        }
        else if t == .octalNumber { number = to }
        
        
        
        
        print(renderedShellScriptPath)
        if checkIfFileExits(renderedShellScriptPath) {
            print("exists")
            let fm = FileManager.default
            
            var attributes = [FileAttributeKey : Any]()
            attributes[.posixPermissions] = number // to
            do {
                try fm.setAttributes(attributes, ofItemAtPath: renderedShellScriptPath)
            }catch let error {
                print("Permissions error: ", error)
            }
            return true
        } else {
            return false
        }
        
        
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







