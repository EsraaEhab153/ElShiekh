//
//  DSGoogleButton.swift
//  Authentication
//

import SwiftUI
import Common

public struct DSGoogleButton: View {
    @Environment(\.dsColors) private var dsColors
    
    public var title: String
    public var action: () -> Void
    
    public init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: DSSpacing.sm) {
                Image(systemName: "g.circle.fill")
                    .font(.title2)
                Text(title)
                    .dsFont(DSTypography.buttonText)
            }
            .foregroundColor(dsColors.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DSSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: DSRadius.sm)
                    .fill(dsColors.surfaceContainerLow)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DSRadius.sm)
                    .stroke(dsColors.outlineVariant, lineWidth: 1)
            )
        }
    }
}
