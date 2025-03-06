//
//  FirebaseAnalytics.swift
//  Kumbaram
//
//

import FirebaseAnalytics

public protocol AnalyticsManaging {
    func logEvent(name: String, params: [String: Any]?)
}


public final class AnalyticsManager: AnalyticsManaging {
 
    public static let shared = AnalyticsManager()
    
    private init() {}    
    
    public func logEvent(name: String, params: [String: Any]? = nil) {
        Analytics.logEvent(name, parameters: params)
    }
    
}

extension AnalyticsManager {
    public enum EventName {
        public static let matchDetail = "match_detail"
        public static let addToCart = "add_to_cart"
        public static let removeFromCart = "remove_from_cart"
    }
}

