//
//  File.swift
//  
//
//  Created by Gregor Feigel on 24.06.21.
//

import Foundation
//import Queuer
import Darwin


/*
 
 run shell script
 
 - timeout handler -> if task it not done in n seconds the task will be terminated
 - return error and standard output separate
 - return only error output
 - return Bool - if error occurred or not
 - no output, just realtime printing the output
 
 */


 
/* in progress */

public class runScript {
    
    public init(scriptPath: String) {
        self.scriptPath = scriptPath
    }
    
    public var scriptPath : String
    public var launchPath : String = "/bin/bash"
    public var arg : String = "-c"
    public var timeout : TimeInterval = 300 // intervall time in sec 
    
    public func shellPipe()  -> (output: String, error: String) {
        
        let sh = shellTimeout(scriptPath, launchPath: launchPath, arg: arg, timeOut: timeout)
        
        return (sh.output, sh.error)
    }
    
    public func shellPrintRealTime() {
        
        shellLifeTimeout(scriptPath, launchPath: launchPath, arg: arg, timeOut: timeout)
        
    }
    
    public func shellErrorsOnly()  -> String {
        
        let sh = shellErrorOnlyOutput(scriptPath, launchPath: launchPath, arg: arg, timeOut: timeout)
        
        return sh
    }
    
    public func shellBool()  -> Bool {
        
        let sh = shellErrorOnlyOutput(scriptPath, launchPath: launchPath, arg: arg, timeOut: timeout)
        
        if sh.isEmpty {return true }
        else { return false }
    }
    
    
}



/// # returns the shell output split into error and output, no timeout function and no real time output
/// - Parameters:
///   - command:  command to execute
///   - launchPath: launch path
///   - arg:  e.g. -c
/// - Returns: output split into error and output
func shell(_ command: String, launchPath: String, arg: String) -> (output: String, error: String) {
    
    let task = Process()
    let pipe = Pipe()
    let error = Pipe()
    
    task.standardOutput = pipe
    task.standardError = error
    task.arguments = [arg, command]
    task.launchPath = launchPath
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let errorData = error.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)!
    let outputError = String(data: errorData, encoding: .utf8)!
    
    
    return (output, outputError)
}


/* shell with timeout */

func shellTimeout(_ command: String, launchPath: String, arg: String, timeOut: TimeInterval) -> (output: String, error: String) {
    
    let task = Process()
    let pipe = Pipe()
    let error = Pipe()
    
    /* setup */
    
    task.standardOutput = pipe
    task.standardError = error
    task.arguments = [arg, command]
    task.launchPath = launchPath
    
    let info = ProcessInfo()
    let begin = info.systemUptime
    
    task.launch()
    /* auto kill process if it takes to long */
    
    if timeOut == .infinity {} else {
        DispatchQueue.global(qos: .background).async {
            
            while task.isRunning == true {
                
                if info.systemUptime - begin <= timeOut { }
                else {
                    usleep(250000) // 1000000 1.000.000
                    task.terminate()
                    print("timeout !!!!!!")
                
                }
                
            }
         
        }
    }
    
    
    
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let errorData = error.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)!
    let outputError = String(data: errorData, encoding: .utf8)!
    
    
    return (output, outputError)
}


/* shell with timeout and error only output */

func shellErrorOnlyOutput(_ command: String, launchPath: String, arg: String, timeOut: TimeInterval) -> String {
    
    let task = Process()
    
    let error = Pipe()
    let pp = Pipe()
    /* setup */
    
    task.standardOutput = pp 
    task.standardError = error
    task.arguments = [arg, command]
    task.launchPath = launchPath
    
    let info = ProcessInfo()
    let begin = info.systemUptime
    print("launch task")
    task.launch()
    /* auto kill process if it takes to long */
    
    if timeOut == .infinity {} else {
        DispatchQueue.global(qos: .background).async {
            
            while task.isRunning == true {
                
                if info.systemUptime - begin <= timeOut { }
                else {
                    usleep(250000) // 1000000 1.000.000
                    task.terminate()
                    print("timeout !!!!!!")
                
                }
                
            }
         
        }
    }
     
    let errorData = error.fileHandleForReading.readDataToEndOfFile()
    let outputError = String(data: errorData, encoding: .utf8)!
    
    
    return outputError
}


/* shell with timeout and real time output and no return with common output */
//@discardableResult
func shellLifeTimeout(_ command: String, launchPath: String, arg: String, timeOut: TimeInterval) {
    
    let task = Process()
    let pipe = Pipe()
    
    /* setup */
    
    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = [arg, command]
    task.launchPath = launchPath
    let info = ProcessInfo()
    let begin = info.systemUptime
    print("launch task")
    task.launch()
    /* auto kill process if it takes to long */
    
    if timeOut == .infinity {} else {
        DispatchQueue.global(qos: .background).async {
            
            while task.isRunning == true {
                
                if info.systemUptime - begin <= timeOut { }
                else {
                    usleep(250000) // 1000000 1.000.000
                    task.terminate()
                    print("timeout !!!!!!")
                
                }
                
            }
         
        }
    }
    
    let outputHandler = pipe.fileHandleForReading
    outputHandler.waitForDataInBackgroundAndNotify()
    
    var output = ""
    var dataObserver: NSObjectProtocol!
    let notificationCenter = NotificationCenter.default
    let dataNotificationName = NSNotification.Name.NSFileHandleDataAvailable
    dataObserver = notificationCenter.addObserver(forName: dataNotificationName, object: outputHandler, queue: nil) {  notification in
        let data = outputHandler.availableData
        guard data.count > 0 else {
            notificationCenter.removeObserver(dataObserver!)
            return
        }
        if let line = String(data: data, encoding: .utf8) {
            
            print(line)
            
            output = output + line + "\n"
        }
        outputHandler.waitForDataInBackgroundAndNotify()
    }
    
    
    task.waitUntilExit()
    
    
}








//public class runner {
//    
//    public init(scriptPath: String) {
//        self.scriptPath = scriptPath
//    }
//
//    public var scriptPath : String
//    
//    let queue = Queuer(name: "MyCustomQueue")
//    
//    
//    public func timeoutStop(_ t: TimeInterval = 15) {
//        
//        DispatchQueue.global(qos: .userInitiated).async {
////            DispatchQueue.main.asyncAfter(deadline: .now() + t) {
//            sleep(UInt32(t))
//            print("timeout !!!!!!")
//            self.queue.cancelAll()
////        }
//            
//        }
//
//    }
//    
//    
//    public func task() {
//         
//        queue.addOperation {
//            while true {
//                
//                sleep(1)
//                print("is running1")
//               
//            }
//        }
//        
//    }
//    
//   
//    public func stop() {
//        queue.cancelAll()
////        print("forceStop")
//    }
//    
//    
//    
//}