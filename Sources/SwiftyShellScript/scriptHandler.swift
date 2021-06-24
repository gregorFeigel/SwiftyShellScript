//
//  File.swift
//  
//
//  Created by Gregor Feigel on 24.06.21.
//

import Foundation


/* beta tasks */

public class scriptInfo {
    
    
    public init(path: String) {
        self.path = path
    }

    public var path: String
    let fileManager = FileManager.default
    
    
    /* get posix permissions */
    
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
    

    
    
    
}















private func test() {
    
    
    
    let fileManager = FileManager.default
    let documentdirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    let filePath = documentdirectory?.appendingPathComponent("rTest.sh").path

    do {
        let fileAttribute = try fileManager.attributesOfItem(atPath: filePath!)
        let fileSize = fileAttribute[FileAttributeKey.size] as! Int64
        let fileType = fileAttribute[FileAttributeKey.type] as! String
        let permissions = fileAttribute[FileAttributeKey.posixPermissions] as! Int16
        let fileCreationDate = fileAttribute[FileAttributeKey.creationDate] as! Date
        
        print("size", fileSize)
        print(fileType)
        print(fileCreationDate)
        print(permissions)
        
    } catch let error {
        print(error.localizedDescription)
    }
    
}
