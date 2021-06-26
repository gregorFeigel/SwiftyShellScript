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
    
    public func runDefault()  -> shellOutput {
        
        let sh = shellTimeout(scriptPath, launchPath: launchPath, arg: arg, timeOut: timeout)
        
        return shellOutput(standardOutput: sh.standardOutput, standardError: sh.standardError, processTime: sh.processTime, timeoutInterrupt: sh.timeoutInterrupt, terminationStatus: sh.terminationStatus, error: sh.error)
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


 

//MARK: - shell with timeout

func shellTimeout(_ command: String, launchPath: String, arg: String, timeOut: TimeInterval) -> shellOutput {
    
    let task = Process()
    let pipe = Pipe()
    let error = Pipe()
    
    var timeoutInterrupt = Bool()
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
    
    let info = ProcessInfo()
    let begin = info.systemUptime
    
    if #available(macOS 10.13, *) {
    do { try task.run()   }
    catch { return shellOutput(standardOutput: "", standardError: "", processTime: info.systemUptime - begin, timeoutInterrupt: false, terminationStatus: task.terminationStatus, error: "\(task.terminationReason)") }
    } else {
    task.launch()
    }
    
    
    
    
    /* auto kill process if it takes to long */
    
    if timeOut == .infinity {} else {
        DispatchQueue.global(qos: .background).async {
            
            while task.isRunning == true {
                
                if info.systemUptime - begin <= timeOut { }
                else {
                    usleep(250000) // 1000000 1.000.000
                    task.terminate()
                    print("timeout !!!!!!")
                    timeoutInterrupt = true
                
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
    
    
    return shellOutput(standardOutput: output, standardError: outputError, processTime: pTime, timeoutInterrupt: timeoutInterrupt, terminationStatus: task.terminationStatus, error: "")
}


//MARK: - shell with timeout and error only output

func shellErrorOnlyOutput(_ command: String, launchPath: String, arg: String, timeOut: TimeInterval) -> String {
    
    let task = Process()
    
    let error = Pipe()
    let pp = Pipe()
    /* setup */
    
    task.standardOutput = pp 
    task.standardError = error
    task.arguments = [arg, command]
    if #available(macOS 10.13, *) {
        task.executableURL = URL(fileURLWithPath: launchPath)
    } else {
        task.launchPath = launchPath
    }
    
    let info = ProcessInfo()
    let begin = info.systemUptime
    print("launch task")
    
    if #available(macOS 10.13, *) {
        do { try task.run() }
        catch { return "something went wrong" }
    } else {
        task.launch()
    }
    
    
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



//MARK: - shell with realtime output and timeout

/* shell with timeout and real time output and no return with common output */
//@discardableResult
func shellLifeTimeout(_ command: String, launchPath: String, arg: String, timeOut: TimeInterval) {
    
    let task = Process()
    let pipe = Pipe()
    
    /* setup */
    
    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = [arg, command]
    if #available(macOS 10.13, *) {
        task.executableURL = URL(fileURLWithPath: launchPath)
    } else {
        task.launchPath = launchPath
    }
    let info = ProcessInfo()
    let begin = info.systemUptime
    print("launch task")
    
    if #available(macOS 10.13, *) {
        do { try task.run() }
        catch { print(task.terminationStatus) }
    } else {
    task.launch()
    }
   
    
    
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
    
    print("\n" + "-------------------------\n" + "this task took: ", info.systemUptime - begin, "seconds")
    
    
}


public struct shellOutput {
    
    public var standardOutput: String
    public var standardError: String
    public var processTime: Double
    public var timeoutInterrupt: Bool
    public var terminationStatus: Int32
    public var error: String
    
    
}
