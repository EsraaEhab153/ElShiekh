//
//  SplashView.swift
//  ElShiekh
//
//  Created by Esraa Ehab on 17/08/2026.
//

import SwiftUI

public struct SplashView: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    
    public init() {}
    
    public var body: some View {
        if isActive {
            ContentView()
        } else {
            VStack {
                VStack {
                    Image("elshiekh_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                        .background(Color.App.background)
                        .scaleEffect(size)
                        .opacity(opacity)
                        .onAppear {
                            withAnimation(.easeIn(duration: 1.2)) {
                                self.size = 1.0
                                self.opacity = 1.0
                            }
                        }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(red: 247 / 255.0, green: 247 / 255.0, blue: 247 / 255.0))
                .ignoresSafeArea()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation {
                            self.isActive = true
                        }
                    }
                }
            }
        }
    }
}
