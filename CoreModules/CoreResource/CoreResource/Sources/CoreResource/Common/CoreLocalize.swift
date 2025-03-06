//
//  CoreLocalize.swift
//  
//
//  Created by Ozcan Akkoca on 7.01.2024.
//

import Foundation

public struct CoreLocalize {
    public struct General {

        public static var OkButton: String {
            return NSLocalizedString("general_ok_button", bundle: .module, comment: "General")
        }
        
        public static var Warning: String {
            return NSLocalizedString("general_warning", bundle: .module, comment: "General")
        }
        
        public static var EmptyCart: String {
            return NSLocalizedString("general_empty_cart", bundle: .module, comment: "General")
        }
    
           
    }
    
    public struct Home {
        public static var Title: String { return NSLocalizedString("home_title", bundle: .module, comment: "Home") }
        public static var Search: String { return NSLocalizedString("home_search", bundle: .module, comment: "Home") }
        public static var Match: String { return NSLocalizedString("home_match", bundle: .module, comment: "Home") }

    }
    
    public struct Cart {
        public static var Title: String { return NSLocalizedString("cart_title", bundle: .module, comment: "Cart") }
        public static var Price: String { return NSLocalizedString("cart_price", bundle: .module, comment: "Cart") }
        public static var Play: String { return NSLocalizedString("cart_play", bundle: .module, comment: "Cart") }
        public static var Total: String { return NSLocalizedString("cart_total", bundle: .module, comment: "Cart") }
        public static var Congratulations: String { return NSLocalizedString("cart_congratulations", bundle: .module, comment: "Cart") }
        public static var Created: String { return NSLocalizedString("cart_created", bundle: .module, comment: "Cart") }
    }
}
