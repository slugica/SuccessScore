//
//  View+Keyboard.swift
//  SuccessClaude
//
//  Created by Claude on 12/30/25.
//

import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
