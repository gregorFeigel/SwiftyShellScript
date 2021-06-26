//
//  File.swift
//  
//
//  Created by Gregor Feigel on 23.06.21.
//

import Foundation
import CryptoKit

extension String {
    
    @available(macOS 10.15, *)
    func asSHA256() -> String {
        
        let inputData = Data(self.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
        
    }
    
    
    func getContentBetween(from: String, to: String) -> String? {
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
    
    
    func replaceBetween(from: String, to: String, by new: String) -> String {
        guard let from = range(of: from)?.upperBound, let to = range(of: to)?.lowerBound else { return self }
        
        let range = from..<to
        return replacingCharacters(in: range, with: new)
    }
    
    
    mutating func removeAndReplaceString(items: [String], with: [String] ) -> String {
        
        var replaced = self
        
        for (n ,t) in zip(items, with) {
            if replaced.contains(n) {
                replaced = replaced.replacingOccurrences(of: n, with: t)
            } else {}
        }
        
        return replaced
    }
    
    func remove(items: [String]) -> String {
        
        var replaced = self
        
        for n in items {
            replaced = replaced.replacingOccurrences(of: n, with: "")
            
        }
        
        return replaced
    }
    
    
    
}

extension Array where Element == String {
    
    mutating func removeFromArray(txt: String) {
        
        if self.contains(txt) {
            
            if let index = self.firstIndex(of: txt) {
                self.remove(at: index)
            }
            
        } else {}
        
        
        
    }
    
    
    mutating func removeAllFromArray(txt: String) {
        
        if self.contains(txt) {
            
            self.removeAll(where: { txt.contains($0) })
            
        } else {}
        
        
        
    }
    
    mutating func removeAllEmptyItemsFromArray() {
        
        if self.contains("") {
            
            self.removeAll(where: { $0.isEmpty })
            
        } else {}
        
        
        
    }
}
