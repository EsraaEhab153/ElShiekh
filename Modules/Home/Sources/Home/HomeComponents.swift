import SwiftUI
import Common

public struct HomeHeaderView: View {
    public init() {}
    
    public var body: some View {
        HStack(alignment: .top) {
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
    }
}

public struct StatusCardView: View {
    @Binding var isOnline: Bool
    var onToggle: (Bool) -> Void
    
    public init(isOnline: Binding<Bool>, onToggle: @escaping (Bool) -> Void) {
        self._isOnline = isOnline
        self.onToggle = onToggle
    }
    
    public var body: some View {
        HStack {
            // Left Circle
            Circle()
                .fill(isOnline ? Color.App.primary: Color.App.grayText.opacity(0.5))
                .frame(width: 16, height: 16)
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(isOnline ? "You are available" : "You are offline")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color.App.primary)
                
                Text(isOnline ? "Waiting for incoming requests..." : "Enable your availability to receive meeting requests")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(Color.App.grayText)
                    .multilineTextAlignment(.trailing)
            }
            
            // Right Toggle
            // FIX: Custom Binding ensures onToggle only fires on USER taps,
            // not on programmatic changes from the ViewModel (e.g., API failure reverts).
            // This eliminates the re-entrant onChange → double API call loop.
            Toggle("", isOn: Binding(
                get: { isOnline },
                set: { newValue in
                    print("🎚️ [StatusCardView] Toggle tapped by user → \(newValue)")
                    isOnline = newValue
                    onToggle(newValue)
                }
            ))
                .labelsHidden()
                .tint(Color.App.primary)
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
    }
}

public struct IncomingRequestCardView: View {
    var studentName: String
    var onAccept: () -> Void
    var onReject: () -> Void
    
    public init(studentName: String, onAccept: @escaping () -> Void, onReject: @escaping () -> Void) {
        self.studentName = studentName
        self.onAccept = onAccept
        self.onReject = onReject
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            Text("Incoming Request")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color.App.primary)
            
            Text("\(studentName) wants to start a study session")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color.App.grayText)
            
            HStack(spacing: 16) {
                Button(action: onReject) {
                    Text("Reject")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color.App.destructive)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.App.destructive, lineWidth: 1)
                        )
                }
                
                Button(action: onAccept) {
                    Text("Accept")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.App.primary)
                        )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.App.cardBackground)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}
