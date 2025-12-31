//
//  AutomationRisk.swift
//  SuccessClaude
//
//  Created by Claude on 12/29/24.
//

import SwiftUI

struct AutomationRiskData: Codable {
    let automationRisks: [OccupationRisk]
    let metadata: RiskMetadata

    enum CodingKeys: String, CodingKey {
        case automationRisks = "automation_risks"
        case metadata
    }
}

struct OccupationRisk: Codable {
    let socCode: String
    let title: String
    let category: String
    let aiRisk: Double
    let roboticsRisk: Double
    let overallRisk: Double

    enum CodingKeys: String, CodingKey {
        case socCode = "soc_code"
        case title
        case category
        case aiRisk = "ai_risk"
        case roboticsRisk = "robotics_risk"
        case overallRisk = "overall_risk"
    }
}

struct RiskMetadata: Codable {
    let version: String
    let lastUpdated: String
    let sources: [String]
    let note: String

    enum CodingKeys: String, CodingKey {
        case version
        case lastUpdated = "last_updated"
        case sources
        case note
    }
}

// MARK: - Risk Assessment Helpers

extension OccupationRisk {
    enum RiskLevel {
        case low
        case medium
        case high

        var color: Color {
            switch self {
            case .low: return .green
            case .medium: return .orange
            case .high: return .red
            }
        }

        var emoji: String {
            switch self {
            case .low: return "🟢"
            case .medium: return "🟡"
            case .high: return "🔴"
            }
        }

        var label: String {
            switch self {
            case .low: return "Low Risk"
            case .medium: return "Medium Risk"
            case .high: return "High Risk"
            }
        }

        var description: String {
            switch self {
            case .low:
                return "Your role has strong resistance to automation. Key tasks require human judgment, creativity, and interpersonal skills."
            case .medium:
                return "Some tasks may be automated, but core responsibilities will likely remain human-driven. Focus on developing uniquely human skills."
            case .high:
                return "Significant automation exposure. Consider developing complementary skills and staying adaptable to technological changes."
            }
        }
    }

    var overallRiskLevel: RiskLevel {
        switch overallRisk {
        case 0..<30: return .low
        case 30..<60: return .medium
        default: return .high
        }
    }

    var aiRiskLevel: RiskLevel {
        switch aiRisk {
        case 0..<30: return .low
        case 30..<60: return .medium
        default: return .high
        }
    }

    var roboticsRiskLevel: RiskLevel {
        switch roboticsRisk {
        case 0..<30: return .low
        case 30..<60: return .medium
        default: return .high
        }
    }

    var primaryThreat: String {
        if aiRisk > roboticsRisk {
            return "AI/LLM"
        } else if roboticsRisk > aiRisk {
            return "Physical Automation"
        } else {
            return "Both AI and Robotics"
        }
    }

    var detailedExplanation: String {
        let aiPart: String
        let roboticsPart: String

        // AI explanation
        if aiRisk >= 60 {
            aiPart = "High exposure to AI/LLM. Many cognitive tasks in this role can be assisted or replaced by language models and AI systems."
        } else if aiRisk >= 30 {
            aiPart = "Moderate AI exposure. Some routine analytical tasks may be automated, but complex decision-making remains human."
        } else {
            aiPart = "Low AI exposure. This role requires human judgment, empathy, or physical presence that AI cannot replicate."
        }

        // Robotics explanation
        if roboticsRisk >= 60 {
            roboticsPart = "High robotics exposure. Physical tasks in this role are increasingly being automated through robotics and machinery."
        } else if roboticsRisk >= 30 {
            roboticsPart = "Moderate robotics exposure. Some repetitive physical tasks may be automated, but skilled manual work remains."
        } else {
            roboticsPart = "Low robotics exposure. This role involves complex physical tasks or human interaction that robots cannot easily replicate."
        }

        return "\(aiPart)\n\n\(roboticsPart)"
    }

    var timeframeEstimate: String {
        switch overallRisk {
        case 0..<30:
            return "Low risk for at least 15+ years"
        case 30..<60:
            return "Moderate changes expected in 5-10 years"
        default:
            return "Significant automation possible in 3-7 years"
        }
    }
}

// MARK: - SOC Code Mapping

struct SOCMapping: Codable {
    let mappings: [String: String]
    let metadata: MappingMetadata
}

struct MappingMetadata: Codable {
    let version: String
    let lastUpdated: String
    let description: String
    let note: String

    enum CodingKeys: String, CodingKey {
        case version
        case lastUpdated = "last_updated"
        case description
        case note
    }
}
