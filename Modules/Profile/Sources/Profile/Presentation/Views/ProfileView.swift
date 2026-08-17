import SwiftUI
import Common

public struct ProfileView: View {
    @StateObject private var viewModel: ProfileViewModel
    @AppStorage("themeSelection") private var themeSelection = 0 // 0: System, 1: Light, 2: Dark
    
    public init(viewModel: ProfileViewModel = ProfileViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    private var themeTitle: String {
        switch themeSelection {
        case 1: return "Light"
        case 2: return "Dark"
        default: return "System"
        }
    }
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    Divider()
                    
                    // User Info
                    userInfoCard
                    
                    Divider()
                    
                    // Settings Options
                    VStack(spacing: 0) {
                        settingsRow(icon: "person.text.rectangle", title: "Edit Sheikh Profile")
                        Divider().padding(.leading, 16)
                        
                        Menu {
                            Button("System") { themeSelection = 0 }
                            Button("Light") { themeSelection = 1 }
                            Button("Dark") { themeSelection = 2 }
                        } label: {
                            HStack(spacing: 16) {
                                Image(systemName: "moon.circle")
                                    .font(.system(size: 22))
                                    .foregroundColor(Color.App.grayText)
                                    .frame(width: 28)
                                
                                Text("Theme")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Text(themeTitle)
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.App.grayText)
                                
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color.App.grayText.opacity(0.6))
                            }
                            .padding(.vertical, 16)
                            .padding(.horizontal, 24)
                            .background(Color(UIColor.systemBackground))
                        }
                        
                        Divider().padding(.leading, 16)
                    }
                    .padding(.top, 16)
                    
                    // Logout Button
                    Button(action: {
                        viewModel.logout()
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Logout")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            Capsule()
                                .stroke(Color.App.grayText.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 32)
                    
                    // Delete Account Button (matches the red text at the bottom of the screenshot)
                    // Delete Account Button (matches the red text at the bottom of the screenshot)
                    Button(action: {
                        // Delete account logic
                    }) {
                        Text("Delete Account")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color.App.destructive)
                            .frame(maxWidth: .infinity) 
                            .padding(.vertical, 16)
                            .background(
                                Capsule()
                                    .stroke(Color.App.destructive, lineWidth: 1) 
                            )
                    }
                    .padding(.horizontal, 24) 
                    .padding(.top, 16)
                    .padding(.bottom, 32)}}
            .background(Color(UIColor.systemBackground).ignoresSafeArea())
            .navigationTitle("Account")
        }
    }
    
    private var userInfoCard: some View {
        HStack(spacing: 16) {
            // Avatar
            Text(viewModel.profile.firstLetter)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color.App.primary)
                .frame(width: 64, height: 64)
                .background(Color.App.primary.opacity(0.1))
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.App.primary, lineWidth: 1.5)
                )
            
            // Text Info
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.profile.username)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(viewModel.profile.email)
                    .font(.system(size: 14))
                    .foregroundColor(Color.App.grayText)
            }
            
            Spacer()
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 24)
        .background(Color(UIColor.systemBackground))
    }
    
    private func settingsRow(icon: String, title: String) -> some View {
        Button(action: {
            // Action for row
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(Color.App.grayText)
                    .frame(width: 28)
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary) 
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color.App.grayText.opacity(0.6))
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .background(Color(UIColor.systemBackground))
        }
    }
}
