//
//  Logger.swift
//  PeePal
//
//  Created by Thomas Patrick on 3/25/26.
//

import OSLog

extension Logger {
    static var subsystem = Bundle.main.bundleIdentifier!
    
    static func `for`(_ category: String) -> Logger {
        Logger(subsystem: subsystem, category: category)
    }
    
    static func `for`<T>(_ thing: T) -> Logger {
        Logger.for(String(describing: type(of: thing)))
    }
}
