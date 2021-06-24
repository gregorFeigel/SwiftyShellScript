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
    
    do { return try String(contentsOf: filename, encoding: .utf8)  }
    catch { return "error" }
    
}
