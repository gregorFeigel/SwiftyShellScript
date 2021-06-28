//
//  File.swift
//
//  Licence: MIT
//  Created by Gregor Feigel on 25.06.21.
//



import Foundation
import CoreServices


/**
 
 file information
 
 - get file information
 - check if file exists
 
 */

/* in progress */

private func valueForSelectedKey(_ t: URLResourceKey,  path: URL) -> URLResourceValues { //URLResourceKey URLResourceValues
    
    var item = URLResourceValues() //: Any = (Any).self
    
    do {
        item = try path.resourceValues(forKeys: [t]) //setResourceValue(NSNumber(value: true), forKey: URLResourceKey.isExcludedFromBackupKey)
        
    } catch let error {
        print(error.localizedDescription)
        
    }
    
    
    
    return item
}


private func valuesForSelectedType(_ t: FileAttributeKey, path: String) -> Any {//FileAttributeKey
    
    var item : Any = (Any).self
    do {
        let fileAttribute = try FileManager.default.attributesOfItem(atPath: path)
        item = fileAttribute[t] as Any
        
    }
    catch let error {
        print(error.localizedDescription)
        
    }
    return item
    
}

//
//private func mditem() {
//    
//    let path = someURL.path
//    if let mditem = MDItemCreate(nil, path as CFString),
//       let mdnames = MDItemCopyAttributeNames(mditem),
//       let mdattrs = MDItemCopyAttributes(mditem, mdnames) as? [String:Any] {
//        print(mdattrs)
//        print("Creator: \(mdattrs[kMDItemCreator as String] as? String ?? "Unknown")")
//    } else {
//        print("Can't get attributes for \(path)")
//    }
//    
//}

private extension fileInfo  { // public extension String {
    
    private func validatePath() -> Bool {
        
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: self.path) {
            return true
        } else {
            return false
        }
        
    }
    
    private func stringToUrl() -> URL {
        return URL(fileURLWithPath: self.path)
    }
}





//MARK: - get file attributes

public extension fileInfo  { // public extension String {
    
    func fileExists() -> Bool {
        
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: self.path) {
            return true
        } else {
            return false
        }
    }
    
    //MARK: - creationDate
    
    func creationDate() -> Date? {
        if self.validatePath() == false { return nil } else {
            return valuesForSelectedType(.creationDate, path: self.path) as? Date
        }
    }
    
    
    //MARK: - modificationDate
    
    func modificationDate() -> Date? {
        if self.validatePath() == false { return nil } else {
            return valuesForSelectedType(.modificationDate, path: self.path) as? Date
        }
    }
    
    
    //MARK: - posixPermissions
    
    func posixPermissions(as t: numberType) -> Int16? {
        if self.validatePath() == false { return nil } else {
            let poisix = valuesForSelectedType(.posixPermissions, path: self.path) as! Int16
            if t == .octalNumber { return poisix }
            
            else {
                
                let octString = String(poisix, radix: 0o10, uppercase: false)
                return Int16(octString) ?? nil
            }
            
        }
    }
    
    
    //MARK: - isBusy
    
    func isBusy() -> Bool? {
        if self.validatePath() == false { return nil } else {
            return valuesForSelectedType(.busy, path: self.path) as? Bool
        }
    }
    
    //MARK: - isAppendOnly
    
    func isAppendOnly() -> Bool? {
        if self.validatePath() == false { return nil } else {
            return valuesForSelectedType(.appendOnly, path: self.path) as? Bool
        }
    }
    
    //MARK: - extensionHidden
    
    func extensionHidden() -> Bool? {
        if self.validatePath() == false { return nil } else {
            return valuesForSelectedType(.extensionHidden, path: self.path) as? Bool
        }
    }
    
    //MARK: - immutable
    
    func isImmutable() -> Bool? {
        if self.validatePath() == false { return nil } else {
            return valuesForSelectedType(.immutable, path: self.path) as? Bool
        }
    }
    
    
    //MARK: - type
    
    func type() -> String? {
        if self.validatePath() == false { return nil } else {
            return valuesForSelectedType(.type, path: self.path) as? String
        }
    }
    
    
    //MARK: - deviceIdentifier
    
    func deviceIdentifier() -> NSNumber? {
        if self.validatePath() == false { return nil } else {
            return valuesForSelectedType(.deviceIdentifier, path: self.path) as? NSNumber
        }
    }
    
    
    //MARK: - groupOwnerAccountID
    
    func groupOwnerAccountID() -> NSNumber? {
        if self.validatePath() == false { return nil } else {
            return valuesForSelectedType(.groupOwnerAccountID, path: self.path) as? NSNumber
        }
    }
    
    //MARK: - groupOwnerAccountName
    
    func groupOwnerAccountName() -> String? {
        if self.validatePath() == false { return nil } else {
            return valuesForSelectedType(.groupOwnerAccountName, path: self.path) as? String
        }
    }
    
    //MARK: - ownerAccountName
    
    func ownerAccountName() -> String? {
        if self.validatePath() == false { return nil } else {
            return valuesForSelectedType(.ownerAccountName, path: self.path) as? String
        }
    }
    
    //MARK: - protectionKey
    
    func protectionKey() -> String? {
        if self.validatePath() == false { return nil } else {
            return valuesForSelectedType(.protectionKey, path: self.path) as? String
        }
    }
    
    //MARK: - systemSize
    
    func systemSize() -> NSNumber? {
        if self.validatePath() == false { return nil } else {
            return valuesForSelectedType(.systemSize, path: self.path) as? NSNumber
        }
    }
    
    
    //MARK: - fileSize
    
    func fileSize(_ t: size = .byte ) -> Double? {
        if self.validatePath() == false { return nil } else {
            let number = valuesForSelectedType(.size, path: self.path) as! Int64
            
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
        
        
    }
    
    
}


public extension fileInfo {
    
    //MARK: - isExecutableKey
    
    func isExecutable() -> Bool? {
        if self.validatePath() == false { return nil } else {
            return valueForSelectedKey(.isExecutableKey, path: self.stringToUrl()).isExecutable
        }
    }
    
    
    //MARK: - isReadableKey
    
    func isReadable() -> Bool? {
        if self.validatePath() == false { return nil } else {
            return valueForSelectedKey(.isReadableKey, path: self.stringToUrl()).isReadable
        }
    }
    
    //MARK: - isWritableKey
    
    func isWritable() -> Bool? {
        if self.validatePath() == false { return nil } else {
            return valueForSelectedKey(.isWritableKey, path: self.stringToUrl()).isWritable
        }
    }
    
    
    
    //MARK: - isVolumeKey
    
    func isVolume() -> Bool? {
        if self.validatePath() == false { return nil } else {
            return valueForSelectedKey(.isVolumeKey, path: self.stringToUrl()).isVolume
        }
    }
    
    //MARK: - isPackageKey
    
    func isPackage() -> Bool? {
        if self.validatePath() == false { return nil } else {
            return valueForSelectedKey(.isPackageKey, path: self.stringToUrl()).isPackage
        }
    }
    
    //MARK: - isAliasFileKey
    
    func isAliasFile() -> Bool? {
        if self.validatePath() == false { return nil } else {
            return valueForSelectedKey(.isAliasFileKey, path: self.stringToUrl()).isAliasFile
        }
    }
    
    //MARK: - isDirectoryKey
    
    func isDirectory() -> Bool? {
        if self.validatePath() == false { return nil } else {
            return valueForSelectedKey(.isDirectoryKey, path: self.stringToUrl()).isDirectory
        }
    }
    
    
    
    //MARK: - isRegularFileKey
    
    func isRegularFile() -> Bool? {
        if self.validatePath() == false { return nil } else {
            return valueForSelectedKey(.isRegularFileKey, path: self.stringToUrl()).isRegularFile
        }
    }
    
    //MARK: - isSymbolicLinkKey
    
    func isSymbolicLink() -> Bool? {
        if self.validatePath() == false { return nil } else {
            return valueForSelectedKey(.isSymbolicLinkKey, path: self.stringToUrl()).isSymbolicLink
        }
    }
    
    //MARK: - addedToDirectoryDateKey
    
    func addedToDirectoryDate() -> Date? {
        if self.validatePath() == false { return nil } else {
            return valueForSelectedKey(.addedToDirectoryDateKey, path: self.stringToUrl()).addedToDirectoryDate
        }
    }
    
    
    
}


//MARK: - get file key values


public enum size {
    case byte
    case kiloByte
    case megaByte
    case gigaByte
}








