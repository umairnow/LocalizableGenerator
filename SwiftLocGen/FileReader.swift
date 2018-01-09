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
    var path: String
    var jsonString: String?
    var firstLanguageKey: String?
    var secondLanguageKey: String?

    init() {
        console.writeMessage("Enter Json Path: ")
        path = console.getInput()
        readFile()
    }
// /Users/umairaamir/Desktop/translation.json
    private func readFile() {
        do {
            jsonString = try String(contentsOfFile: path)
            console.writeMessage("Enter 1st language key:")
            firstLanguageKey = console.getInput()
            console.writeMessage("Enter 2nd language key:")
            secondLanguageKey = console.getInput()
            parseJson()
        } catch {
            print(error.localizedDescription)
        }
    }

    private func parseJson() {
        guard let json = jsonString else {
            console.writeMessage("Json not found")
            return
        }
        guard let langKey1 = firstLanguageKey,
        let langKey2 = secondLanguageKey else {
            console.writeMessage("Language keys are required")
            return
        }
        let parser: JsonParserProtocol = JsonParser()
        do {
            let dictionary = try parser.parseJson(json)
            let generator: GeneratorProtocol = Generator()
            let path = generator.generateFiles(from: dictionary,
                                               with: langKey1,
                                               and: langKey2)
            console.writeMessage("Files generated at: \(path)")
        } catch {
            print(error.localizedDescription)
        }
    }
}
