import Foundation

protocol ColorDatabaseProtocol {
    func colors(forEnvironment environment: String) -> [ColorInfo]
    func availableEnvironments() -> [String]
    func color(named name: String) -> ColorInfo?
    func getAllColors() -> [ColorInfo]
}