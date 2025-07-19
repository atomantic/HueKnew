import Foundation
@testable import HueKnew

class MockColorDatabase: ColorDatabaseProtocol {
    var mockEnvironmentColors: [String: [ColorInfo]] = [:]

    func colors(forEnvironment environment: String) -> [ColorInfo] {
        return mockEnvironmentColors[environment.lowercased()] ?? []
    }

    func availableEnvironments() -> [String] {
        return Array(mockEnvironmentColors.keys).sorted()
    }

    func color(named name: String) -> ColorInfo? {
        // Implement if needed for specific tests, otherwise return nil
        return nil
    }

    func getAllColors() -> [ColorInfo] {
        // Implement if needed for specific tests, otherwise return empty array
        return []
    }
}