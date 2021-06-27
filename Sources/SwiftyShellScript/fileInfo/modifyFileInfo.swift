//
//  File.swift
//
//  Licence: MIT
//  Created by Gregor Feigel on 25.06.21.
//


/**
 
 file information
 
 - modify file information:
 - file posix permissions
 - file name
 
 
 */

/* in progress */

import Foundation

class modify {
    
    internal init(_ path: String) {
        self.path = path
    }
    
    var path: String
    
    
    // TODO:  functions for all modifiable infos
    
    
    //MARK: - rename file
    
    public func rename(to: String)  -> Bool {
        
        if checkIfFileExits() == true {
            
            var origin = URL(fileURLWithPath: path)
            
            do {
                var rv = URLResourceValues()
                rv.name = to
                try origin.setResourceValues(rv)
            }
            catch let error {
                print(error.localizedDescription)
                return false
            }
            return true
            
        } else { return false }
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
        if checkIfFileExits() {
            
            do {
                
                var attributes = [FileAttributeKey : Any]()
                attributes[.posixPermissions] = number // to
                
                try fm.setAttributes(attributes, ofItemAtPath: path)
                
            } catch { return false  }
            
            return true
            
        } else { return false }
        
        
    }
    
    
    
    //MARK: - check if file exists
    
    
    
    private func checkIfFileExits() -> Bool {
        
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path) {
            return true
        } else {
            return false
        }
        
    }
    
    
    
}
