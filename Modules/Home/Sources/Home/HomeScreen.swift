import SwiftUI
import Common

public struct HomeScreen: View {
    @State private var selectedTab: TabItem = .home
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.App.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack(alignment: .top) {
                    // Avatar
                    Circle()
                        .fill(Color.App.primary)
                        .frame(width: 48, height: 48)
                        .overlay(
                            Text("EE")
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .bold))
                        )
                    
                    Spacer()
                    
                    // Welcome Text
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Al Maher")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color.App.primary)
                        
                        Text("Welcome back") // Added wave emoji as typical for welcome, though optional
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color.App.primary)
                        Text("Manage your availability status and study circles")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color.App.grayText)
                            .multilineTextAlignment(.trailing)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                
                // Status Card
                HStack {
                    // Left Circle
                    Circle()
                        .fill(Color.App.grayText.opacity(0.5))
                        .frame(width: 16, height: 16)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("You are offline")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color.App.primary)
                        
                        Text("Enable your availability to receive meeting requests")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(Color.App.grayText)
                    }
                    
                    // Right small dot
                    Circle()
                        .fill(Color.App.grayText.opacity(0.5))
                        .frame(width: 8, height: 8)
                        .padding(.leading, 12)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.App.cardBackground)
                )
                .padding(.horizontal, 24)
                .padding(.top, 32)
                
                Spacer()
                
                // Tab Bar
                CustomTabBar(selectedTab: $selectedTab)
            }
        }
    }
}

#Preview {
    HomeScreen()
}
