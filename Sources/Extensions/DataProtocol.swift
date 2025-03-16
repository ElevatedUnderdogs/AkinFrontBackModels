//
//  DataProtocol.swift
//
//
//  Created by Leonardo Dabus on 07/05/24.
//
import Foundation
import protocol Foundation.DataProtocol

#if canImport(Vapor)
import Vapor

extension DataProtocol {
    var sha256digest: SHA256Digest { SHA256.hash(data: self) }
    var sha384digest: SHA384Digest { SHA384.hash(data: self) }
    var sha512digest: SHA512Digest { SHA512.hash(data: self) }
}
#endif

#if canImport(Crypto)
import Crypto

extension DataProtocol {
    var sha256digest: SHA256Digest { SHA256.hash(data: self) }
    var sha384digest: SHA384Digest { SHA384.hash(data: self) }
    var sha512digest: SHA512Digest { SHA512.hash(data: self) }
}
#endif

#if canImport(CryptoKit)
import CryptoKit

extension DataProtocol {
    var sha256digest: SHA256Digest { SHA256.hash(data: self) }
    var sha384digest: SHA384Digest { SHA384.hash(data: self) }
    var sha512digest: SHA512Digest { SHA512.hash(data: self) }
}
#endif
