//
//  SwiftUIView.swift
//  Authentication
//
//  Created by Nadin Ahmed on 20/07/2026.
//

import SwiftUI
import Common

struct HeaderSection: View {
    @Environment(\.dsColors) private var dsColors
    
    var title: String
    var description: String
    
    var body: some View {
        VStack(spacing: DSSpacing.xs) {
            ZStack {
                RoundedRectangle(cornerRadius: DSRadius.sm)
                    .fill(dsColors.primary)
                    .frame(width: 44, height: 44)
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.bottom, DSSpacing.xs)

            Text("Al-Mahir")
                .dsFont(DSTypography.labelMedium)
                .foregroundColor(dsColors.textSecondary)

            Text(title)
                .dsFont(DSTypography.headlineMedium)
                .foregroundColor(dsColors.textPrimary)
                .padding(.top, DSSpacing.xs)

            Text(description)
                .dsFont(DSTypography.bodyMedium)
                .foregroundColor(dsColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, DSSpacing.md)
        .padding(.top, DSSpacing.xl)
    }
}
