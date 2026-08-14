//
//  AppButton.swift
//  Authentication
//

import SwiftUI
import Common

public struct AppButton: View {
    @Environment(\.dsColors) private var dsColors
    
    public var title: String
    public var action: () -> Void
    
    public init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Text(title)
                .dsFont(DSTypography.headlineMedium)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DSSpacing.md)
                .background(dsColors.primary)
                .cornerRadius(DSRadius.md)
        }
    }
}
