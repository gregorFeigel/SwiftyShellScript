//
//  File.swift
//  
//
//  Created by Gregor Feigel on 23.06.21.
//

import Foundation

extension String {
    
    func getContentBetween(from: String, to: String) -> String? {
          return (range(of: from)?.upperBound).flatMap { substringFrom in
              (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                  String(self[substringFrom..<substringTo])
              }
          }
      }
    
    
    func replaced(from: String, to: String, by new: String) -> String {
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
    
    

}
