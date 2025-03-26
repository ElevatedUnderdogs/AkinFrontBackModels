//
//  File.swift
//  AkinFrontBackModels
//
//  Created by Scott Lydon on 3/6/25.
//

import Foundation

/// An enum representing base language codes from Locale.availableIdentifiers, based on common Apple-supported languages.
/// Note: The total number of unique base languages in Locale.availableIdentifiers may exceed this list and varies by OS version.
/// This enum includes 40 languages as a representative sample as of March 06, 2025.
public enum LanguageCodeEnum: RawRepresentable, Codable, CaseIterable, Equatable, Hashable {

    /// Represents a supported language code from the predefined set.
    case supported(SupportedLanguageCode)
    /// Represents an unsupported language code, allowing flexibility for other valid codes.
    case unsupported(String)

    /// Initializes a LanguageCode from a raw string value.
    /// - Parameter rawValue: A string representing a language code (e.g., "en", "fr").
    /// - Returns: A LanguageCode instance if the rawValue matches a supported code, or an unsupported case; nil if invalid.
    public init?(rawValue: String) {
        let trimmedValue = rawValue.lowercased()
        if let supported = SupportedLanguageCode(rawValue: trimmedValue) {
            self = .supported(supported)
        } else if !trimmedValue.isEmpty {
            self = .unsupported(trimmedValue)
        } else {
            return nil
        }
    }

    /// The raw value type is String, representing the language code.
    public typealias RawValue = String

    /// A static collection of all supported language cases.
    public static var allCases: [LanguageCodeEnum] {
        return SupportedLanguageCode.allCases.map { LanguageCodeEnum.supported($0) }
    }

    /// Returns the raw string value of the language code.
    public var rawValue: String {
        switch self {
        case .supported(let supported):
            return supported.rawValue
        case .unsupported(let code):
            return code
        }
    }

    public init(supportedLanguage: SupportedLanguageCode) {
        self = .supported(supportedLanguage)
    }

    /// Initializes a LanguageCode from a string literal.
    /// - Parameter value: A string literal representing a language code (e.g., "en", "fr").
    public init(stringLiteral value: String) {
        if let code = LanguageCodeEnum(rawValue: value) {
            self = code
        } else {
            self = .unsupported(value)
        }
    }

    /// Returns the localized name of the language based on the current locale.
    public var localizedName: String {
        Locale.current.localizedString(forLanguageCode: rawValue) ?? rawValue
    }
}

/// An enum defining the supported base language codes with detailed documentation.
public enum SupportedLanguageCode: String, Codable, CaseIterable, Equatable, Hashable {
    /// 1. English - A widely spoken language, primarily in the United States, United Kingdom, Canada, Australia, and others.
    case en
    /// 2. French - A Romance language spoken in France, Canada (Quebec), Belgium, Switzerland, and parts of Africa.
    case fr
    /// 3. Spanish - A Romance language dominant in Spain, Mexico, much of Latin America, and parts of the United States.
    case es
    /// 4. German - A West Germanic language spoken in Germany, Austria, Switzerland, and parts of Belgium and Italy.
    case de
    /// 5. Italian - A Romance language spoken in Italy, Switzerland, and parts of Croatia and Slovenia.
    case it
    /// 6. Portuguese - A Romance language spoken in Portugal, Brazil, Angola, Mozambique, and others.
    case pt
    /// 7. Japanese - An East Asian language spoken in Japan.
    case ja
    /// 8. Chinese (Simplified) - A Sino-Tibetan language spoken in China, Singapore, and Malaysia.
    case zh
    /// 9. Russian - An East Slavic language spoken in Russia, Ukraine, Belarus, and parts of Central Asia.
    case ru
    /// 10. Arabic - A Semitic language spoken across the Middle East and North Africa.
    case ar
    /// 11. Korean - A language isolate spoken in South Korea and North Korea.
    case ko
    /// 12. Dutch - A West Germanic language spoken in the Netherlands and Belgium (Flanders).
    case nl
    /// 13. Swedish - A North Germanic language spoken in Sweden and parts of Finland.
    case sv
    /// 14. Danish - A North Germanic language spoken in Denmark.
    case da
    /// 15. Norwegian - A North Germanic language spoken in Norway.
    case no
    /// 16. Finnish - A Uralic language spoken in Finland.
    case fi
    /// 17. Polish - A West Slavic language spoken in Poland.
    case pl
    /// 18. Czech - A West Slavic language spoken in the Czech Republic.
    case cs
    /// 19. Hungarian - A Uralic language spoken in Hungary.
    case hu
    /// 20. Turkish - A Turkic language spoken in Turkey and Cyprus.
    case tr
    /// 21. Greek - An Indo-European language spoken in Greece and Cyprus.
    case el
    /// 22. Hebrew - A Semitic language spoken in Israel.
    case he
    /// 23. Thai - A Kra-Dai language spoken in Thailand.
    case th
    /// 24. Vietnamese - An Austroasiatic language spoken in Vietnam.
    case vi
    /// 25. Indonesian - A Malayo-Polynesian language spoken in Indonesia.
    case id
    /// 26. Malay - A Malayo-Polynesian language spoken in Malaysia, Brunei, and Singapore.
    case ms
    /// 27. Hindi - An Indo-Aryan language spoken in India.
    case hi
    /// 28. Bengali - An Indo-Aryan language spoken in Bangladesh and parts of India.
    case bn
    /// 29. Tamil - A Dravidian language spoken in India, Sri Lanka, and Singapore.
    case ta
    /// 30. Telugu - A Dravidian language spoken in India.
    case te
    /// 31. Urdu - An Indo-Aryan language spoken in Pakistan and parts of India.
    case ur
    /// 32. Persian - An Iranian language spoken in Iran, Afghanistan, and Tajikistan.
    case fa
    /// 33. Ukrainian - An East Slavic language spoken in Ukraine.
    case uk
    /// 34. Romanian - A Romance language spoken in Romania and Moldova.
    case ro
    /// 35. Croatian - A South Slavic language spoken in Croatia.
    case hr
    /// 36. Serbian - A South Slavic language spoken in Serbia and Bosnia.
    case sr
    /// 37. Slovak - A West Slavic language spoken in Slovakia.
    case sk
    /// 38. Bulgarian - A South Slavic language spoken in Bulgaria.
    case bg
    /// 39. Catalan - A Romance language spoken in Catalonia (Spain), Andorra, and parts of France.
    case ca
    /// 40. Basque - A language isolate spoken in the Basque Country (Spain and France).
    case eu
}
