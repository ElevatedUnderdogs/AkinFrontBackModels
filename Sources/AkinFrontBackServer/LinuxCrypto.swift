//
//  File.swift
//  AkinFrontBackModels
//
//  Created by Scott Lydon on 3/15/25.
//

import Foundation

#if os(Linux) // ✅ Linux only
import Crypto

extension Data {
    var sha256digest: Data { Data(SHA256.hash(data: self)) }
    var sha384digest: Data { Data(SHA384.hash(data: self)) }
    var sha512digest: Data { Data(SHA512.hash(data: self)) }
}

extension StringProtocol {
    var data: Data { .init(utf8) }
    var sha256hexa: String { data.sha256digest.map { String(format: "%02x", $0) }.joined() }
    var sha384hexa: String { data.sha384digest.map { String(format: "%02x", $0) }.joined() }
    var sha512hexa: String { data.sha512digest.map { String(format: "%02x", $0) }.joined() }
}
#endif
