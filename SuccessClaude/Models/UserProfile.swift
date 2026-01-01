//
//  UserProfile.swift
//  SuccessClaude
//
//  Created by Claude on 12/28/25.
//

import Foundation

// MARK: - Universal Region Model

struct Region: Codable, Identifiable, Hashable {
    let code: String
    let name: String
    let countryCode: String

    var id: String { code }

    enum CodingKeys: String, CodingKey {
        case code
        case name
        case countryCode = "country_code"
    }
}

// MARK: - User Profile

struct UserProfile: Codable {
    var countryCode: String
    var region: Region
    var zipCode: String
    var city: String
    var age: Int
    var annualIncome: Double
    var householdIncome: Double
    var numberOfChildren: Int
    var gender: Gender
    var maritalStatus: MaritalStatus
    var occupation: OccupationCategory

    // Legacy property for backward compatibility
    var state: USState {
        get {
            if countryCode == "us", let usState = USState(rawValue: region.code) {
                return usState
            }
            return .california
        }
        set {
            region = Region(code: newValue.rawValue, name: newValue.fullName, countryCode: "us")
            countryCode = "us"
        }
    }

    init() {
        self.countryCode = "us"
        self.region = Region(code: "CA", name: "California", countryCode: "us")
        self.zipCode = ""
        self.city = ""
        self.age = 30
        self.annualIncome = 0
        self.householdIncome = 0
        self.numberOfChildren = 0
        self.gender = .notSelected
        self.maritalStatus = .notSelected
        self.occupation = OccupationCategory(socCode: "", title: "", category: "", countryCode: "us")
    }

    init(countryCode: String, region: Region) {
        self.countryCode = countryCode
        self.region = region
        self.zipCode = ""
        self.city = ""
        self.age = 30
        self.annualIncome = 0
        self.householdIncome = 0
        self.numberOfChildren = 0
        self.gender = .notSelected
        self.maritalStatus = .notSelected
        self.occupation = OccupationCategory(socCode: "", title: "", category: "", countryCode: countryCode)
    }

    // Computed properties
    var isMarried: Bool {
        maritalStatus == .married
    }

    var householdSize: Int {
        if isMarried {
            return 2 + numberOfChildren // you + spouse + children
        } else {
            return 1 // just you
        }
    }

    var perCapitaIncome: Double {
        if isMarried && householdSize > 0 {
            return householdIncome / Double(householdSize)
        } else {
            return annualIncome
        }
    }

    var effectiveIncome: Double {
        if isMarried {
            // Use householdIncome if available, otherwise fallback to annualIncome
            return householdIncome > 0 ? householdIncome : annualIncome
        } else {
            return annualIncome
        }
    }

    /// OECD Modified Equivalence Scale for household income comparison
    /// - First adult = 1.0
    /// - Additional adults (spouse) = 0.5
    /// - Each child = 0.3
    var equivalenceScale: Double {
        if isMarried {
            // 1.0 (you) + 0.5 (spouse) + 0.3 * numberOfChildren
            return 1.0 + 0.5 + (0.3 * Double(numberOfChildren))
        } else {
            return 1.0
        }
    }

    /// Equivalised income using OECD scale - used for comparing living standards
    /// across households of different sizes (standard methodology used by ABS)
    var equivalisedIncome: Double {
        if isMarried && householdIncome > 0 {
            return householdIncome / equivalenceScale
        } else {
            return annualIncome
        }
    }

    /// Income to use for statistical comparisons (Success Score, percentile rankings)
    /// - For Australia: Uses equivalised income for fair household comparison
    /// - For US: Uses effective income (household for married, personal for single)
    /// - For others: Uses effective income
    var comparisonIncome: Double {
        if countryCode == "au" && isMarried && householdIncome > 0 {
            return equivalisedIncome
        } else {
            return effectiveIncome
        }
    }
}

enum Gender: String, Codable, CaseIterable, Identifiable {
    case notSelected = ""
    case male = "Male"
    case female = "Female"
    case other = "Other"

    var id: String { rawValue }

    var localizedName: String {
        switch self {
        case .notSelected: return "Select Gender"
        case .male: return NSLocalizedString("gender.male", value: "Male", comment: "Male gender")
        case .female: return NSLocalizedString("gender.female", value: "Female", comment: "Female gender")
        case .other: return NSLocalizedString("gender.other", value: "Other", comment: "Other gender")
        }
    }
}

enum MaritalStatus: String, Codable, CaseIterable, Identifiable {
    case notSelected = ""
    case single = "Single"
    case married = "Married"
    case divorced = "Divorced"
    case widowed = "Widowed"

    var id: String { rawValue }

    var localizedName: String {
        switch self {
        case .notSelected: return "Select Status"
        case .single: return NSLocalizedString("marital.single", value: "Single", comment: "Single")
        case .married: return NSLocalizedString("marital.married", value: "Married", comment: "Married")
        case .divorced: return NSLocalizedString("marital.divorced", value: "Divorced", comment: "Divorced")
        case .widowed: return NSLocalizedString("marital.widowed", value: "Widowed", comment: "Widowed")
        }
    }
}

enum USState: String, Codable, CaseIterable, Identifiable {
    case alabama = "AL"
    case alaska = "AK"
    case arizona = "AZ"
    case arkansas = "AR"
    case california = "CA"
    case colorado = "CO"
    case connecticut = "CT"
    case delaware = "DE"
    case florida = "FL"
    case georgia = "GA"
    case hawaii = "HI"
    case idaho = "ID"
    case illinois = "IL"
    case indiana = "IN"
    case iowa = "IA"
    case kansas = "KS"
    case kentucky = "KY"
    case louisiana = "LA"
    case maine = "ME"
    case maryland = "MD"
    case massachusetts = "MA"
    case michigan = "MI"
    case minnesota = "MN"
    case mississippi = "MS"
    case missouri = "MO"
    case montana = "MT"
    case nebraska = "NE"
    case nevada = "NV"
    case newHampshire = "NH"
    case newJersey = "NJ"
    case newMexico = "NM"
    case newYork = "NY"
    case northCarolina = "NC"
    case northDakota = "ND"
    case ohio = "OH"
    case oklahoma = "OK"
    case oregon = "OR"
    case pennsylvania = "PA"
    case rhodeIsland = "RI"
    case southCarolina = "SC"
    case southDakota = "SD"
    case tennessee = "TN"
    case texas = "TX"
    case utah = "UT"
    case vermont = "VT"
    case virginia = "VA"
    case washington = "WA"
    case westVirginia = "WV"
    case wisconsin = "WI"
    case wyoming = "WY"
    case districtOfColumbia = "DC"

    var id: String { rawValue }

    var fullName: String {
        switch self {
        case .alabama: return "Alabama"
        case .alaska: return "Alaska"
        case .arizona: return "Arizona"
        case .arkansas: return "Arkansas"
        case .california: return "California"
        case .colorado: return "Colorado"
        case .connecticut: return "Connecticut"
        case .delaware: return "Delaware"
        case .florida: return "Florida"
        case .georgia: return "Georgia"
        case .hawaii: return "Hawaii"
        case .idaho: return "Idaho"
        case .illinois: return "Illinois"
        case .indiana: return "Indiana"
        case .iowa: return "Iowa"
        case .kansas: return "Kansas"
        case .kentucky: return "Kentucky"
        case .louisiana: return "Louisiana"
        case .maine: return "Maine"
        case .maryland: return "Maryland"
        case .massachusetts: return "Massachusetts"
        case .michigan: return "Michigan"
        case .minnesota: return "Minnesota"
        case .mississippi: return "Mississippi"
        case .missouri: return "Missouri"
        case .montana: return "Montana"
        case .nebraska: return "Nebraska"
        case .nevada: return "Nevada"
        case .newHampshire: return "New Hampshire"
        case .newJersey: return "New Jersey"
        case .newMexico: return "New Mexico"
        case .newYork: return "New York"
        case .northCarolina: return "North Carolina"
        case .northDakota: return "North Dakota"
        case .ohio: return "Ohio"
        case .oklahoma: return "Oklahoma"
        case .oregon: return "Oregon"
        case .pennsylvania: return "Pennsylvania"
        case .rhodeIsland: return "Rhode Island"
        case .southCarolina: return "South Carolina"
        case .southDakota: return "South Dakota"
        case .tennessee: return "Tennessee"
        case .texas: return "Texas"
        case .utah: return "Utah"
        case .vermont: return "Vermont"
        case .virginia: return "Virginia"
        case .washington: return "Washington"
        case .westVirginia: return "West Virginia"
        case .wisconsin: return "Wisconsin"
        case .wyoming: return "Wyoming"
        case .districtOfColumbia: return "District of Columbia"
        }
    }

    static func fromCode(_ code: String) -> USState? {
        return USState(rawValue: code)
    }
}

struct OccupationCategory: Codable, Identifiable, Hashable {
    let socCode: String
    let title: String
    let category: String
    let countryCode: String

    var id: String { "\(countryCode)_\(socCode)" }

    enum CodingKeys: String, CodingKey {
        case socCode = "soc_code"
        case title
        case category
        case countryCode = "country_code"
    }

    // Legacy initializer for backward compatibility
    init(socCode: String, title: String, category: String) {
        self.socCode = socCode
        self.title = title
        self.category = category
        self.countryCode = "us"
    }

    init(socCode: String, title: String, category: String, countryCode: String) {
        self.socCode = socCode
        self.title = title
        self.category = category
        self.countryCode = countryCode
    }
}
