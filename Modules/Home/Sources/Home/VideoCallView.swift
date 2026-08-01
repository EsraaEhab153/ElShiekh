import SwiftUI
import Common

public struct VideoCallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isConnecting = true
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if isConnecting {
                ConnectingView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                isConnecting = false
                            }
                        }
                    }
            } else {
                ActiveCallView(onEndCall: {
                    dismiss()
                })
            }
        }
    }
}

#Preview {
    VideoCallView()
}
