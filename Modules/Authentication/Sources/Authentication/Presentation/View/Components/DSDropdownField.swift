//
//  DSDropdownField.swift
//  Authentication
//

import SwiftUI
import Common

public struct DSDropdownField: View {
    @Environment(\.dsColors) private var dsColors
    
    public var label: String?
    public var placeholder: String
    @Binding public var selection: String
    public var options: [String]
    public var leadingIcon: String?
    
    public init(
        label: String? = nil,
        placeholder: String,
        selection: Binding<String>,
        options: [String],
        leadingIcon: String? = nil
    ) {
        self.label = label
        self.placeholder = placeholder
        self._selection = selection
        self.options = options
        self.leadingIcon = leadingIcon
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            if let label {
                Text(label)
                    .dsFont(DSTypography.labelMedium)
                    .foregroundColor(dsColors.textSecondary)
            }
            
            Menu {
                ForEach(options, id: \.self) { option in
                    Button(option) {
                        selection = option
                    }
                }
            } label: {
                HStack(spacing: DSSpacing.sm) {
                    if let leadingIcon {
                        Image(systemName: leadingIcon)
                            .font(.system(size: 16))
                            .foregroundColor(dsColors.textSecondary)
                            .frame(width: 20)
                    }
                    
                    Text(selection.isEmpty ? placeholder : selection)
                        .dsFont(DSTypography.bodyMedium)
                        .foregroundColor(selection.isEmpty ? dsColors.textSecondary.opacity(0.5) : dsColors.textPrimary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14))
                        .foregroundColor(dsColors.textSecondary)
                }
                .padding(.horizontal, DSSpacing.md)
                .padding(.vertical, DSSpacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: DSRadius.sm)
                        .fill(dsColors.surfaceContainerLow)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: DSRadius.sm)
                        .stroke(dsColors.surfaceVariant, lineWidth: 1)
                )
            }
        }
    }
}
