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
struct AppSetting<Value>: DynamicProperty {
    let setting: Setting
    @AppStorage private var storage: Value
    
    init(_ setting: Setting) where Value: Saveable, Value: RawRepresentable, Value.RawValue == String {
        let defaultValue = Value.defaultValue
        self.setting = setting
        self._storage = .init(wrappedValue: defaultValue, setting.rawValue)
    }
    
    init(_ setting: Setting) where Value == Bool {
        self.setting = setting
        self._storage = .init(wrappedValue: false, setting.rawValue)
    }
    
    var wrappedValue: Value {
        get { storage }
        nonmutating set { storage = newValue }
    }
    
    var projectedValue: Binding<Value> {
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

protocol Saveable {
    static var defaultValue: Self { get }
}

enum Appearance: String, CaseIterable, Saveable {
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

enum DirectionsProvider: String, CaseIterable, Saveable {
    case apple = "Apple Maps"
    case google = "Google Maps"
    
    static var defaultValue: DirectionsProvider {
        .apple
    }
}

enum MapMode: String, CaseIterable, Saveable {
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
