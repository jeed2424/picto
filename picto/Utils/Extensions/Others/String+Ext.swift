import Foundation
import UIKit

extension String {
    func noSpaces() -> String {
        return self.replacingOccurrences(of: " ", with: "")
    }

    func findMentionText() -> [String] {
         let words = self.components(separatedBy: " ")
         var hashTags = [String]()
         for word in words{
             if word.hasPrefix("#"){
//                 let hashtag = word.dropFirst()
                 hashTags.append(String(word))
             }
         }
        return hashTags
    }

    private func getHashTags(from caption: String) -> [String] {
        var words: [String] = []
        let texts = caption.components(separatedBy: " ")
        for text in texts.filter({ $0.hasPrefix("#") }) {
            if text.count > 1 {
                let subString = String(text.suffix(text.count - 1))
                words.append(subString.lowercased())
            }
        }
        return words
    }

    mutating func removeTags() -> String {
        var new = self
        for i in self.findMentionText() {
            print("HASH: ", i)
            new = new.replacingOccurrences(of: i, with: "")
            for e in self.findMentionText() {
                new = new.replacingOccurrences(of: e, with: "")
            }
        }
        let ind = new.split(separator: "#")
        if !ind.isEmpty {
            new = String(ind[0])
        }
        new = new.replacingOccurrences(of: "#", with: "")
        new = new.trim()
        return new
    }

    func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.newlines)
    }
}

public extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}
