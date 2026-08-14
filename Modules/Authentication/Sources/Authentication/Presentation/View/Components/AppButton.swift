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
    @Environment(\.isEnabled) private var isEnabled
    
    public var body: some View {
        Button(action: action) {
            Text(title)
                .dsFont(DSTypography.buttonText)
                .foregroundColor(dsColors.onPrimary)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, DSSpacing.md)
                .padding(.vertical, DSSpacing.smMd)
                .background(isEnabled ? dsColors.primary : dsColors.primary.opacity(0.12))
                .cornerRadius(DSRadius.md)
        }
    }
}
