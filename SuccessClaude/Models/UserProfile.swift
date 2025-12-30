//
//  UserProfile.swift
//  SuccessClaude
//
//  Created by Claude on 12/28/25.
//

import Foundation

struct UserProfile: Codable {
    var zipCode: String
    var state: USState
    var city: String
    var age: Int
    var annualIncome: Double
    var householdIncome: Double
    var numberOfChildren: Int
    var gender: Gender
    var maritalStatus: MaritalStatus
    var occupation: OccupationCategory

    init() {
        self.zipCode = ""
        self.state = .california
        self.city = ""
        self.age = 30
        self.annualIncome = 0
        self.householdIncome = 0
        self.numberOfChildren = 0
        self.gender = .notSelected
        self.maritalStatus = .notSelected
        self.occupation = OccupationCategory(socCode: "", title: "", category: "")
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
        return isMarried ? householdIncome : annualIncome
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

    var id: String { socCode }
}
