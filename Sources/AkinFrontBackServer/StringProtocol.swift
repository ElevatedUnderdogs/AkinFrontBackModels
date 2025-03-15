//
//  File.swift
//  
//
//  Created by Leonardo Dabus on 07/05/24.
//

import Foundation
import protocol Foundation.DataProtocol
import protocol Foundation.ContiguousBytes
import struct Foundation.Data

#if canImport(Vapor)
import enum Vapor.AES
#elseif canImport(Crypto)
import enum Crypto.AES
#elseif canImport(CryptoKit)
import enum CryptoKit.AES
#endif

extension StringProtocol {

    var hexaData: Data { .init(hexa) }
    var hexaBytes: [UInt8] { .init(hexa) }

    private var hexa: UnfoldSequence<UInt8, Index> {
        sequence(state: startIndex) { startIndex in
            guard startIndex < self.endIndex else { return nil }
            let endIndex = self.index(startIndex, offsetBy: 2, limitedBy: self.endIndex) ?? self.endIndex
            defer { startIndex = endIndex }
            return UInt8(self[startIndex..<endIndex], radix: 16)
        }
    }
}
