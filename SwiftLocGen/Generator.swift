//
//  Generator.swift
//  LocalizableGenerator
//
//  Created by Umair Aamir on 11/16/17.
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

protocol GeneratorProtocol {
    func generateFiles(from translationDictionary: [String: Any],
                       with key1: String,
                       and key2: String) -> String
}

class Generator {
    private func varName(_ key: String) -> String {
        return "static let \(key.lowerCamel()) = "
    }

    private func statement(with key: String, innerKey: String, value: String) -> String {
        return "NSLocalizedString(\"\(key).\(innerKey)\", comment: \"\(value)\")"
    }

    private func signature() -> String {
        let createdDate = Date()
        let createdDateFormtter = DateFormatter()
        createdDateFormtter.dateStyle = .short
        createdDateFormtter.timeStyle = .none
        let copyRightsDate = Date()
        let copyRightsDateFormatter = DateFormatter()
        copyRightsDateFormatter.dateFormat = "YYYY"
        return "//\n//  StringResources.swift\n//  MyBioAge\n//\n//  Created by LocalizableGenerator on \(createdDateFormtter.string(from: createdDate)).\n//  Copyright © \(copyRightsDateFormatter.string(from: copyRightsDate)) UmairAamir Co. All rights reserved.\n//\n\n"
    }

    private func prepareResourceFiles(from translations: [String: Any],
                                      with langKey1: String,
                                      and langKey2: String) -> (swift: String, lang1: String, lang2: String) {
        let allKeys = translations.keys
        var firstLangLocalizable = ""
        var secLangLocalizable = ""
        var swiftClass = signature()
        swiftClass += "final class StringResources {\n"
        let tab = "    "
        for key in allKeys {
            swiftClass += "\n\(tab)final class \(key.removeUnderScores()) {\n"
            if let innerObject = translations[key] as? [String: Any] {
                let allInnerKeys = innerObject.keys
                for innerKey in allInnerKeys {
                    swiftClass += "\(tab)\(tab)"
                    if let valueObject = (innerObject[innerKey] as? [String: String]) {
                        if let lang1 = valueObject[langKey1] {
                            let localizedString = statement(with: key,
                                                            innerKey: innerKey,
                                                            value: replaceQuotes(from: lang1))
                            swiftClass += "\(varName(innerKey))\(localizedString)\n"
                            firstLangLocalizable += "/* \(lang1) */\n"
                            firstLangLocalizable += "\"\(key).\(innerKey)\" = \"\(prepareString(from: lang1))\";\n\n"
                            if let lang2 = valueObject[langKey2] {
                                secLangLocalizable += "/* \(lang1) */\n"
                                secLangLocalizable += "\"\(key).\(innerKey)\" = \"\(prepareString(from: lang2))\";\n\n"
                            }
                        }
                    }
                }
                swiftClass += "\(tab)}\n"
            }
        }
        swiftClass += "}"
        return (swiftClass, firstLangLocalizable, secLangLocalizable)
    }

    private func saveFile(_ classContent: String, className: String, classExtension: String) -> String {
        let defaultManager = FileManager.default
        var documentPath = ""
        if let homeUrl = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first {
            documentPath = homeUrl + "/Translations"
            if defaultManager.fileExists(atPath: documentPath) == false {
                do {
                    try defaultManager.createDirectory(atPath: documentPath, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print(error.localizedDescription)
                }
            }
            let documentUrl = URL(fileURLWithPath: documentPath).appendingPathComponent(className).appendingPathExtension(classExtension)
            do {
                try classContent.write(to: documentUrl, atomically: true, encoding: .utf8)
            } catch {
                print(error.localizedDescription)
            }
        }
        return documentPath
    }

    private func replacePlaceholder(from value: String) -> String {
        guard let start = value.index(of: "<"),
            let end = value.index(of: ">") else {
                return value
        }
        let stringToRemove = value[start...end]
        let newValue = value.replacingOccurrences(of: stringToRemove, with: "%@")
        return replacePlaceholder(from: newValue)
    }

    private func prepareString(from value: String) -> String {
        let quotesReplaced = replaceQuotes(from: value)
        return replacePlaceholder(from: quotesReplaced)
    }

    private func replaceQuotes(from value: String) -> String {
        guard value.contains("\"") else {
            return value
        }
        let doubleQuotes = "\\\""
        return value.replacingOccurrences(of: "\"", with: doubleQuotes)
    }
}

extension Generator: GeneratorProtocol {

    func generateFiles(from translationDictionary: [String: Any],
                       with key1: String,
                       and key2: String) -> String {
        var path = ""
        if let translations = translationDictionary["translations"] as? [String: Any] {
            let files = prepareResourceFiles(from: translations,
                                             with: key1,
                                             and: key2)
            path = saveFile(files.swift, className: "StringResources", classExtension: "swift")
            path = saveFile(files.lang1, className: "Localizable-\(key1)", classExtension: "strings")
            path = saveFile(files.lang2, className: "Localizable-\(key2)", classExtension: "strings")
        }
        return path
    }
}

extension String {
    func removeUnderScores() -> String {
        return self.replacingOccurrences(of: "_", with: "")
    }

    func lowerCamel() -> String {
        var arrArg = components(separatedBy: "_")
        var varName = ""
        for i in 0..<arrArg.count {
            if i == 0 {
                varName = arrArg[i]
            } else {
                varName += arrArg[i].capitalizingFirstLetter()
            }
        }
        return varName
    }

    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
