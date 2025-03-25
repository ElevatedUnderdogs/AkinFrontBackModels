//
//  File.swift
//  
//
//  Created by Leonardo Dabus on 07/05/24.
//

import Foundation

#if canImport(Vapor)
import enum Vapor.AES
#elseif canImport(Crypto)
import enum Crypto.AES
import Crypto
#elseif canImport(CryptoKit)
import enum CryptoKit.AES
import CryptoKit
#endif

// MARK: - Data Digest Extensions (CryptoKit or Crypto/SwiftCrypto)
extension Data {

    var sha256digest: Data {
        #if canImport(CryptoKit)
        return Data(SHA256.hash(data: self))
        #elseif canImport(Crypto)
        return Data(SHA256().hash(self))
        #else
        fatalError("No SHA256 implementation available on this platform.")
        #endif
    }

    var sha384digest: Data {
        #if canImport(CryptoKit)
        return Data(SHA384.hash(data: self))
        #elseif canImport(Crypto)
        return Data(SHA384().hash(self))
        #else
        fatalError("No SHA384 implementation available on this platform.")
        #endif
    }

    var sha512digest: Data {
        #if canImport(CryptoKit)
        return Data(SHA512.hash(data: self))
        #elseif canImport(Crypto)
        return Data(SHA512().hash(self))
        #else
        fatalError("No SHA512 implementation available on this platform.")
        #endif
    }
}

// MARK: - StringProtocol Extension
extension StringProtocol {
    var data: Data { .init(utf8) }
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

    var sha256hexa: String { data.sha256digest.map { String(format: "%02x", $0) }.joined() }
    var sha384hexa: String { data.sha384digest.map { String(format: "%02x", $0) }.joined() }
    var sha512hexa: String { data.sha512digest.map { String(format: "%02x", $0) }.joined() }
}
