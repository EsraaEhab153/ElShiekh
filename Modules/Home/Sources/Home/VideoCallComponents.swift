import SwiftUI
import Common

public struct ConnectingView: View {
    public init() {}
    
    public var body: some View {
        Text("...Connecting")
            .font(.system(size: 24, weight: .semibold))
            .foregroundColor(.white)
    }
}

public struct ActiveCallView: View {
    var onEndCall: () -> Void
    
    public init(onEndCall: @escaping () -> Void) {
        self.onEndCall = onEndCall
    }
    
    public var body: some View {
        VStack {
            // Remote Video (Big Rectangle)
            ZStack(alignment: .topTrailing) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay(
                        Text("Student Video")
                            .font(.headline)
                            .foregroundColor(.white)
                    )
                
                // Local Video (Small Rectangle)
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: 120, height: 160)
                    .cornerRadius(12)
                    .padding()
                    .overlay(
                        Text("You")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    )
                    .shadow(radius: 5)
            }
            
            // Controls
            HStack(spacing: 40) {
                // Mic Button
                Button(action: {}) {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 64, height: 64)
                        .overlay(
                            Image(systemName: "mic.fill")
                                .foregroundColor(.white)
                                .font(.title2)
                        )
                }
                
                // End Call Button
                Button(action: onEndCall) {
                    Circle()
                        .fill(Color.App.destructive)
                        .frame(width: 64, height: 64)
                        .overlay(
                            Image(systemName: "phone.down.fill")
                                .foregroundColor(.white)
                                .font(.title2)
                        )
                }
                
                // Camera Button
                Button(action: {}) {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 64, height: 64)
                        .overlay(
                            Image(systemName: "video.fill")
                                .foregroundColor(.white)
                                .font(.title2)
                        )
                }
            }
            .padding(.bottom, 40)
            .padding(.top, 20)
        }
        .transition(.opacity)
    }
}
