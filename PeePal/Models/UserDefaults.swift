//
//  UserDefaults.swift
//  PeePal
//
//  Created by Thomas Patrick on 12/13/20.
//

import MapKit
import SwiftUI

// MARK: UserDefaults keys

enum Filter: String {
    case accessible = "accessFilter"
    case changingTable = "tableFilter"
    case unisex = "unisexFilter"
}

enum Setting: String {
    case colorScheme = "colorScheme"
    case directionsProvider = "directionsProvider"
    case liquidGlassDisabled = "liquidGlassDisabled"
    case mapMode = "mapMode"
    case offlineMode = "offlineMode"
}

// MARK: UserDefaults property wrappers

@propertyWrapper
struct AppSetting<T: Saveable>: DynamicProperty where T.RawValue == String {
    let setting: Setting
    @AppStorage private var storage: T
    
    init(_ setting: Setting) {
        let defaultValue = T.defaultValue
        self.setting = setting
        self._storage = .init(wrappedValue: defaultValue, setting.rawValue)
    }
    
    var wrappedValue: T {
        get { storage }
        nonmutating set { storage = newValue }
    }
    
    var projectedValue: Binding<T> {
        $storage
    }
}

@propertyWrapper
struct AppFilter: DynamicProperty {
    let filter: Filter
    @AppStorage private var storage: Bool
    
    init(_ filter: Filter) {
        self.filter = filter
        self._storage = .init(wrappedValue: false, filter.rawValue)
    }
    
    var wrappedValue: Bool {
        get { storage }
        nonmutating set { storage = newValue }
    }
    
    var projectedValue: Binding<Bool> {
        $storage
    }
}

// MARK: UserDefaults values

protocol Saveable: RawRepresentable, CaseIterable {
    static var defaultValue: Self { get }
}

extension Bool: @retroactive RawRepresentable {
    public init?(rawValue: String) {
        if rawValue.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "true" {
            self = true
        } else if rawValue.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "false" {
            self = false
        }
        return nil
    }
    
    public var rawValue: String {
        "\(self)"
    }
}
extension Bool: @retroactive CaseIterable {
    public static var allCases: [Bool] {
        [true, false]
    }
}
extension Bool: Saveable {
    static var defaultValue: Bool {
        false
    }
}

enum Appearance: String, Saveable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    
    static var defaultValue: Appearance {
        .system
    }
    
    var scheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

enum DirectionsProvider: String, Saveable {
    case apple = "Apple Maps"
    case google = "Google Maps"
    
    static var defaultValue: DirectionsProvider {
        .apple
    }
}

enum MapMode: String, Saveable {
    case standard = "Standard"
    case satellite = "Satellite"
    case hybrid = "Hybrid"
    
    static var defaultValue: MapMode {
        .standard
    }
    
    var style: MapStyle {
        switch self {
        case .standard: return .standard
        case .satellite: return .imagery
        case .hybrid: return .hybrid
        }
    }
}
