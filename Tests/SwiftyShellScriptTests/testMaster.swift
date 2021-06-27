//
//  File.swift
//
//  Licence: MIT
//  Created by Gregor Feigel on 25.06.21.
//

import Foundation

/*

  download the test files from the testFiles branch and insert below the path to the XCTestSwiftyShellScript folder

*/

func dir(withPath: String) -> String { getDocumentsDirectory().appendingPathComponent("XCTestSwiftyShellScript").path  +  withPath} //  Users/admin/Documents/Xcode/XCTestSwiftyShellScript/







func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}
