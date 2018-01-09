//
//  FileReader.swift
//  SwiftLocGen
//
//  Created by Umair Aamir on 11/26/17.
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

class FileReader {
    let console = ConsoleIO()

    init() {
        console.writeMessage("Enter Json Path: ")
        readFile(atPath: console.getInput())
    }
    
    private func readFile(atPath path: String) {
        do {
            let url = URL(fileURLWithPath: path)
            let jsonData = try Data(contentsOf: url, options: .dataReadingMapped)
            console.writeMessage("Enter 1st language key:")
            let firstLanguageKey = console.getInput()
            console.writeMessage("Enter 2nd language key:")
            let secondLanguageKey = console.getInput()
            parseJson(fromData: jsonData,
                      withFirstLanguageKey: firstLanguageKey,
                      andSecondLanguageKey: secondLanguageKey)
        } catch {
            print(error.localizedDescription)
        }
    }

    private func parseJson(fromData jsonData: Data,
                           withFirstLanguageKey firstLanguageKey: String,
                           andSecondLanguageKey secondLanguageKey: String) {
        guard firstLanguageKey.isEmpty == false &&
        secondLanguageKey.isEmpty == false else {
            console.writeMessage("Language keys are required")
            return
        }
        let parser: JsonParserProtocol = JsonParser()
        do {
            let dictionary = try parser.parseJson(data: jsonData)
            let generator: GeneratorProtocol = Generator()
            let path = generator.generateFiles(from: dictionary,
                                               with: firstLanguageKey,
                                               and: secondLanguageKey)
            console.writeMessage("Files generated at: \(path)")
        } catch {
            print(error.localizedDescription)
        }
    }
}
