//
//  String+KoreanPostposition.swift
//  TweetNestKit
//
//  Created by Mina Her on 2022/09/17.
//

extension String {

    public var resolvingKoreanPostpositions: String {
        KoreanPostpositionResolver.resolvedString(self)
    }

    public mutating func resolveKoreanPostpositions() {
        self = resolvingKoreanPostpositions
    }
}
