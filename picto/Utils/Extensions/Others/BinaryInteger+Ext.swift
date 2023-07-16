import Foundation

#if canImport(CoreGraphics)
import CoreGraphics
#endif

public extension BinaryInteger {
    /// Self Explanatory
    var bool: Bool { self == 1 }

    /// Self Explanatory
    var int: Int { Int(self) }

    /// Self Explanatory
    var uint: UInt { UInt(self) }

    /// Self Explanatory
    var int8: Int8 { Int8(self) }

    /// Self Explanatory
    var uint8: UInt8 { UInt8(self) }

    /// Self Explanatory
    var int16: Int16 { Int16(self) }

    /// Self Explanatory
    var uint16: UInt16 { UInt16(self) }

    /// Self Explanatory
    var int32: Int32 { Int32(self) }

    /// Self Explanatory
    var uint32: UInt32 { UInt32(self) }

    /// Self Explanatory
    var int64: Int64 { Int64(self) }

    /// Self Explanatory
    var uint64: UInt64 { UInt64(self) }

    /// Self Explanatory
    var double: Double { Double(self) }

    /// Self Explanatory
    var float: Float { Float(self) }

    /// Self Explanatory
    var float32: Float32 { Float32(self) }

    /// Self Explanatory
    var float64: Float64 { Float64(self) }

    #if canImport(CoreGraphics)
    /// Self-Explanatory
    var cgf: CGFloat { CGFloat(double) }
    #endif

    /// Self-Explanatory
    var hex: String { String(self, radix: 16, uppercase: true) }
}
