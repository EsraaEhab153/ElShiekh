import ActivityKit
import WidgetKit
import SwiftUI
import AppIntents
import Home // Important: Requires Home framework to be linked to CallWidget target!

struct AnswerCallIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Answer Call"
    
    @Parameter(title: "Request ID")
    var requestId: String
    
    init() {}
    
    init(requestId: String) {
        self.requestId = requestId
    }
    
    func perform() async throws -> some IntentResult {
        // Broadcast to the main app to handle the answer action
        NotificationCenter.default.post(name: NSNotification.Name("AnswerCall"), object: nil, userInfo: ["requestId": requestId])
        return .result()
    }
}

struct DeclineCallIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Decline Call"
    
    @Parameter(title: "Request ID")
    var requestId: String
    
    init() {}
    
    init(requestId: String) {
        self.requestId = requestId
    }
    
    func perform() async throws -> some IntentResult {
        // Broadcast to the main app to handle the decline action
        NotificationCenter.default.post(name: NSNotification.Name("DeclineCall"), object: nil, userInfo: ["requestId": requestId])
        return .result()
    }
}

struct CallWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CallAttributes.self) { context in
            // Lock screen / Banner UI
            HStack {
                VStack(alignment: .leading) {
                    Text(context.attributes.callerName)
                        .font(.headline)
                    Text(context.state.status)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                HStack(spacing: 16) {
                    Button(intent: DeclineCallIntent(requestId: context.attributes.requestId)) {
                        Image(systemName: "phone.down.fill")
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.red)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    
                    Button(intent: AnswerCallIntent(requestId: context.attributes.requestId)) {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.green)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI - Native Call Look
                DynamicIslandExpandedRegion(.leading) {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 44, height: 44)
                            .foregroundColor(.green)
                            .padding(.leading, 8)
                        
                        VStack(alignment: .leading) {
                            Text(context.attributes.callerName)
                                .font(.headline)
                                .lineLimit(1)
                            Text("Incoming Call")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    HStack(spacing: 12) {
                        Button(intent: DeclineCallIntent(requestId: context.attributes.requestId)) {
                            Image(systemName: "phone.down.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 48, height: 48)
                                .background(Color.red)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        
                        Button(intent: AnswerCallIntent(requestId: context.attributes.requestId)) {
                            Image(systemName: "phone.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 48, height: 48)
                                .background(Color.green)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.trailing, 8)
                }
            } compactLeading: {
                Image(systemName: "phone.fill")
                    .foregroundColor(.green)
            } compactTrailing: {
                Text("Call")
            } minimal: {
                Image(systemName: "phone.fill")
                    .foregroundColor(.green)
            }
        }
    }
}
