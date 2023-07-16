import Foundation

public extension Range {
    /// Return a value that is 100% within the specified range.
    func clampedValue(_ value: Bound) -> Bound {
        if value < lowerBound {
            return lowerBound
        }

        if value > upperBound {
            return upperBound
        }

        return value
    }
}

public extension ClosedRange {
    /// Return a value that is 100% within the specified range.
    func clampedValue(_ value: Bound) -> Bound {
        if value < lowerBound {
            return lowerBound
        }

        if value > upperBound {
            return upperBound
        }

        return value
    }
}
