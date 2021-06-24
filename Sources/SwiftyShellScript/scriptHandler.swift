//
//  File.swift
//  
//
//  Created by Gregor Feigel on 24.06.21.
//

import Foundation


    /* not complete */

public class scriptInfo {
    
    
    public init(path: String) {
        self.path = path
    }
    
    public var path: String
    let fileManager = FileManager.default
    
    
    
    //MARK: - check if file already exists
    
    /// check if file already exists
    /// - Parameter t: file path as string e.g. /home/user/Documents/test.sh
    /// - Returns: true if file exits
    
    public func checkIfFileExits() -> Bool {
        
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path) {
            return true
        } else {
            return false
        }
        
    }
    
    
    private func checkIfFileExits(_ t: String) -> Bool {
       
       let fileManager = FileManager.default
       if fileManager.fileExists(atPath: t) {
           return true
       } else {
           return false
       }
       
   }
    
    //MARK: -  get posix permissions
    
    public func getPosixPermissions(as t: numberType) -> Int16 {
        
        var poisix = Int16()
        
        do {
            let fileAttribute = try fileManager.attributesOfItem(atPath: path)
            poisix = fileAttribute[FileAttributeKey.posixPermissions] as! Int16
        }
        
        catch let error {
            print(error.localizedDescription)
        }
        print(poisix)
        if t == .octalNumber { return poisix }
        
        else {
            
            let octString = String(poisix, radix: 0o10, uppercase: false)
            print(octString)
            return Int16(octString) ?? -9999
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
        if checkIfFileExits(path) {
            
            do {
                
                var attributes = [FileAttributeKey : Any]()
                attributes[.posixPermissions] = number // to
                
                try fm.setAttributes(attributes, ofItemAtPath: path)
                
            } catch { return false  }
            
            return true
            
        } else { return false }
        
        
    }
    
    
    
    //MARK: - get file size
    
    public func getFileSize(_ t: size) -> Double {
        
        var number : Int64 = -9999
        
        do {
            let fileAttribute = try FileManager.default.attributesOfItem(atPath: path)
            number = fileAttribute[FileAttributeKey.size] as! Int64
        } catch let error {
            print(error.localizedDescription)
        }
        
        switch t {
        case .byte:
            return Double(number)
            
        case .kiloByte: return Double(number / 1000)
            
        case .megaByte:
            let a = Double(number / 1000)
            return Double(a / 1000)
            
        case .gigaByte:
            let a = Double(number / 1000)
            let b = Double(a / 1000)
            return Double(b / 1000)
            
            
        }
    }
    
    
    //MARK: - get file creation date
    
    public func getCreationDate() -> Date {
        
        var date = Date()
        do {
            let fileAttribute = try fileManager.attributesOfItem(atPath: path)
            date = fileAttribute[FileAttributeKey.creationDate] as! Date
            
        }
        catch let error {
            print(error.localizedDescription)
        }
        return date
    }
    
    
    //MARK: - get file type
    
    public func getFileType() -> String {
        
        var type = ""
        do {
            let fileAttribute = try fileManager.attributesOfItem(atPath: path)
            type = fileAttribute[FileAttributeKey.type] as! String
            
        }
        catch let error {
            print(error.localizedDescription)
        }
        return type
    }
    
    
    
    //MARK: - get file group owner account name
    
    public func getGroupOwnerAccountName() -> String {
        
        var type = ""
        do {
            let fileAttribute = try fileManager.attributesOfItem(atPath: path)
            type = fileAttribute[FileAttributeKey.groupOwnerAccountName] as! String
            
        }
        catch let error {
            print(error.localizedDescription)
        }
        return type
    }
    
    
    
    //MARK: - get file modification date
    
    public func getModificationDate() -> Date {
        
        var date = Date()
        do {
            let fileAttribute = try fileManager.attributesOfItem(atPath: path)
            date = fileAttribute[FileAttributeKey.modificationDate] as! Date
            
        }
        catch let error {
            print(error.localizedDescription)
        }
        return date
    }
    
    
    
}



public enum size {
    case byte
    case kiloByte
    case megaByte
    case gigaByte
}





