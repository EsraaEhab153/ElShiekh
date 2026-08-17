import SwiftUI

public enum TabItem: Int, CaseIterable {
    case profile = 0
    case home = 1
    
    public var title: String {
        switch self {
        case .home:
            return "Home"
        case .profile:
            return "Profile"
        }
    }
    
    public var icon: String {
        switch self {
        case .home:
            // "mappin.and.ellipse" looks a bit like the icon in the image, but maybe just use a custom shape or system icon for home
            // Actually, the home icon in the image looks a bit like a house with a curved roof. `house.fill` is a good proxy.
            return "house.fill"
        case .profile:
            return "person"
        }
    }
}

public struct CustomTabBar: View {
    @Binding public var selectedTab: TabItem
    
    public init(selectedTab: Binding<TabItem>) {
        self._selectedTab = selectedTab
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            // Profile Tab (Left)
            TabBarButton(
                item: .profile,
                isSelected: selectedTab == .profile,
                action: { selectedTab = .profile }
            )
            
            Spacer(minLength: 16)
            
            // Home Tab (Right)
            TabBarButton(
                item: .home,
                isSelected: selectedTab == .home,
                action: { selectedTab = .home }
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.dynamic(light: .white, dark: Color(white: 0.12)))
        .cornerRadius(32)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }
}

private struct TabBarButton: View {
    let item: TabItem
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                // Icon
                Image(systemName: item.icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? Color.App.primary : Color.App.grayText)
                
                // Title
                Text(item.title)
                    .font(.system(size: 14, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? Color.App.primary : Color.App.grayText)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            // Selected background
            .background(
                Capsule()
                    .fill(isSelected ? Color.App.primaryLight : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack {
        Spacer()
        CustomTabBar(selectedTab: .constant(.home))
        CustomTabBar(selectedTab: .constant(.profile))
    }
    .background(Color.gray.opacity(0.1))
}
