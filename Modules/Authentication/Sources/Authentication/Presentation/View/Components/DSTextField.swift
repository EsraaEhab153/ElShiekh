//
//  DSTextField.swift
//  Authentication
//

import SwiftUI
import Common

public struct DSTextField: View {
    @Environment(\.dsColors) private var dsColors
    
    public var label: String
    public var placeholder: String
    @Binding public var text: String
    public var isSecure: Bool
    public var textContentType: UITextContentType?
    public var autocapitalization: TextInputAutocapitalization
    public var autocorrectionDisabled: Bool
    public var keyboardType: UIKeyboardType
    
    public init(
        label: String,
        placeholder: String,
        text: Binding<String>,
        isSecure: Bool = false,
        textContentType: UITextContentType? = nil,
        autocapitalization: TextInputAutocapitalization = .sentences,
        autocorrectionDisabled: Bool = false,
        keyboardType: UIKeyboardType = .default
    ) {
        self.label = label
        self.placeholder = placeholder
        self._text = text
        self.isSecure = isSecure
        self.textContentType = textContentType
        self.autocapitalization = autocapitalization
        self.autocorrectionDisabled = autocorrectionDisabled
        self.keyboardType = keyboardType
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text(label)
                .dsFont(DSTypography.labelMedium)
                .foregroundColor(dsColors.textSecondary)
            
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .padding(DSSpacing.sm)
            .background(dsColors.surfaceVariant.opacity(0.5))
            .cornerRadius(DSRadius.sm)
            .textContentType(textContentType)
            .textInputAutocapitalization(autocapitalization)
            .autocorrectionDisabled(autocorrectionDisabled)
            .keyboardType(keyboardType)
        }
    }
}
