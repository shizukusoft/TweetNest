//
//  KoreanPostpositionResolver.swift
//  TweetNestKit
//
//  Created by Mina Her on 2022/09/13.
//

internal struct KoreanPostpositionResolver: Sendable {

    private static let generalPostpositions: [String: (flat: String, common: String, rieul: String)] = [
        "(가)이": ("가", "이", "이"),
        "(는)은": ("는", "은", "은"),
        "(를)을": ("를", "을", "을"),
        "(야)아": ("야", "아", "아"),
        "(으)로": ("로", "으로", "로"),
        "(이)": ("", "이", "이"),
    ]

    internal static func resolvedString(_ string: String) -> String {
        var remainString = string[...]
        var resolvedString = String()
        for (rule, resolves) in generalPostpositions {
            guard !rule.isEmpty
            else {
                continue
            }
            if
                let firstIndex = remainString.firstIndex(of: rule.first!),
                remainString[firstIndex...].hasPrefix(rule[...])
            {
                resolvedString += remainString[..<firstIndex]
                remainString = remainString[remainString.index(firstIndex, offsetBy: rule.count)...]
                if let lastUnicodeScalar = resolvedString.last.flatMap(String.init(_:))?.decomposedStringWithCanonicalMapping.unicodeScalars.last {
                    switch lastUnicodeScalar.value {
                    case 0x1161 ... 0x1175:
                        resolvedString += resolves.flat
                    case 0x11af:
                        resolvedString += resolves.rieul
                    case 0x11a8 ... 0x11c2:
                        resolvedString += resolves.common
                    default:
                        resolvedString += rule
                    }
                } else {
                    resolvedString += rule
                }
            }
        }
        resolvedString += remainString
        return resolvedString
    }

    private init() {
    }
}
