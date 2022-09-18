//
//  Collection+RangeMatching.swift
//  TweetNestKit
//
//  Created by Mina Her on 2022/09/18.
//

@available(iOS, deprecated: 16)
@available(macOS, deprecated: 13)
@available(watchOS, deprecated: 9)
extension Collection
where Element: Equatable {

    internal func firstRange<C>(of other: C) -> Range<Index>?
    where C: Collection, Element == C.Element {
        guard !isEmpty && !other.isEmpty
        else {
            return nil
        }
        if let firstIndex = firstIndex(of: other.first!) {
            var index = firstIndex
            var otherIndex = other.startIndex
            while otherIndex != other.endIndex {
                defer {
                    formIndex(after: &index)
                    other.formIndex(after: &otherIndex)
                }
                guard index != endIndex
                else {
                    return nil
                }
                if self[index] != other[otherIndex] {
                    return self[self.index(after: firstIndex)...].firstRange(of: other)
                }
            }
            return firstIndex ..< index
        }
        return nil
    }
}
