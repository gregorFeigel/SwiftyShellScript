//
//  File.swift
//  
//
//  Created by Gregor Feigel on 23.06.21.
//

import Foundation



/// reads file at path e.g. /home/user/Documents/test.sh
/// - Parameter path: file path as string
/// - Returns: content as string 
func readFileAtDirection(path: String) -> String {
    
    let filename = URL(fileURLWithPath: path)
    do {
        return try String(contentsOf: filename, encoding: .utf8)
    }
    catch { return "error" }
    
}

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

func writeTo(_ t: String, to: URL) -> Bool {
    
    do {
        try t.write(to: to, atomically: true, encoding: String.Encoding.utf8)
    } catch {
        print(error)
        return false
    }
    return true
}
