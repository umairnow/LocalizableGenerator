//
//  ConsoleIO.swift
//  Converter
//
//  Created by Umair Aamir on 11/10/17.
//
//  MIT License

//  Copyright (c) 2017 umairnow

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation

enum OutputType {
	case error
	case standard
}

class ConsoleIO {
  func writeMessage(_ message: String, to: OutputType = .standard) {
    switch to {
    case .standard:
      // 1
      print("\u{001B}[;m\(message)")
    case .error:
      // 2
      fputs("\u{001B}[0;31m\(message)\n", stderr)
    }
  }
  
  func printUsage() {
    
    let executableName = (CommandLine.arguments[0] as NSString).lastPathComponent
    
    writeMessage("usage:")
    writeMessage("\(executableName) -a string1 string2")
    writeMessage("or")
    writeMessage("\(executableName) -p string")
    writeMessage("or")
    writeMessage("\(executableName) -h to show usage information")
    writeMessage("Type \(executableName) without an option to enter interactive mode.")
  }
  
  func getInput() -> String {
    // 1
    let keyboard = FileHandle.standardInput
    // 2
    let inputData = keyboard.availableData
    // 3
    let strData = String(data: inputData, encoding: String.Encoding.utf8)!
    // 4
    return strData.trimmingCharacters(in: CharacterSet.newlines)
  }
}

