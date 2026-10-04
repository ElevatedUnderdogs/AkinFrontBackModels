//
//  WireCoding.swift
//  AkinFrontBackModels
//
//  GOAL_LOOP28 item 1.3. The single point of truth for how a value crosses the wire
//  between the app and the server.
//
//  WHY THIS FILE EXISTS, stated as the measurement that produced it rather than as a
//  principle. On 2026-10-03 a TestFlight tester on iOS 18.1.1 photographed a black screen
//  carrying one red box reading "This version of the app could not read what came back."
//  The cause was two declarations of one convention, neither visible from the other:
//
//    the server, Sources/App/Extensions/Date+Formatters+Encoders.swift, installed globally
//      encoder.dateEncodingStrategy = .formatted(.iso8601withFractionalSeconds)
//      // "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX", so it writes 2026-10-04T01:11:37.866Z
//
//    the app, akin/Flows/Social/AkinAPI.swift
//      decoder.dateDecodingStrategy = .iso8601
//      // ISO8601DateFormatter with .withInternetDateTime and NOT .withFractionalSeconds,
//      // so it refuses the .866
//
//  Every reply carrying a Date therefore failed to decode on the member's phone. Neither
//  side was wrong on its own terms; they simply never had to agree.
//
//  A SECOND trap, recorded because it nearly closed the investigation with the wrong
//  answer. The same two configurations, copied verbatim into a macOS script, decode each
//  other CLEANLY. macOS builds against swift-foundation, whose `.iso8601` tolerates
//  fractional seconds; iOS 18 builds against the older Foundation, which does not. A
//  platform question answered on the wrong platform reports the defect as absent. The
//  strategy below does not depend on which Foundation it is compiled against, which is the
//  property that makes it safe on both.
//

import Foundation

/// How Map Mates writes an instant on the wire.
///
/// `yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX`, which is what the server has always written. The format
/// is stated here rather than in either consumer so that changing it is one edit in one place
/// and a compile away from both sides.
public enum WireDate {

    /// The canonical spelling, matching the server's existing output byte for byte.
    public static let format = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"

    /// A formatter built per call site rather than shared, because `DateFormatter` is not
    /// thread safe and these are cheap next to a network round trip.
    public static func formatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = format
        return formatter
    }

    /// The same instant WITHOUT fractional seconds.
    ///
    /// Accepted on the way IN and never written on the way out. A client or a server that
    /// predates the fractional form still has its output understood, which is what keeps a
    /// version skew from becoming a black screen. Being liberal in what is accepted and
    /// strict in what is sent is the only part of this file that is a principle.
    public static func fallbackFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
        return formatter
    }

    /// Parse an instant the way both sides agree to read one.
    public static func date(from string: String) -> Date? {
        formatter().date(from: string) ?? fallbackFormatter().date(from: string)
    }

    /// Write an instant the way both sides agree to send one.
    public static func string(from date: Date) -> String {
        formatter().string(from: date)
    }
}

public extension JSONDecoder {

    /// The decoder every Map Mates wire reply is read with, on both platforms.
    ///
    /// `.custom` rather than `.formatted`, so the fractional and non fractional spellings are
    /// both understood, and so the behaviour does not change underneath us when a Foundation
    /// version changes what `.iso8601` tolerates. That substitution is exactly what hid this
    /// defect from a macOS check.
    static var akinWire: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let raw = try container.decode(String.self)
            guard let date = WireDate.date(from: raw) else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Expected \(WireDate.format) or the same without "
                        + "fractional seconds, and got \(raw)."
                )
            }
            return date
        }
        return decoder
    }
}

public extension JSONEncoder {

    /// The encoder every Map Mates wire reply is written with, on both platforms.
    static var akinWire: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.outputFormatting = .withoutEscapingSlashes
        encoder.dateEncodingStrategy = .custom { date, encoder in
            var container = encoder.singleValueContainer()
            try container.encode(WireDate.string(from: date))
        }
        return encoder
    }
}
