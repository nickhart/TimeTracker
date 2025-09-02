# Live Activities Setup
## Activity Attributes
```swift
struct TimerActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var elapsedTime: TimeInterval
        var taskName: String
        var projectName: String
    }

    var startTime: Date
    var clientName: String
}
```

## Widget Implementation
```swift
struct TimerActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimerActivityAttributes.self) { context in
            // Lock Screen UI
            TimerLockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded view
                DynamicIslandExpandedRegion(.center) {
                    TimerExpandedView(context: context)
                }
            } compactLeading: {
                // Compact leading (icon)
                Image(systemName: "timer")
            } compactTrailing: {
                // Compact trailing (time)
                Text(context.state.elapsedTime.formatted())
            } minimal: {
                // Minimal view
                Image(systemName: "timer")
            }
        }
    }
}
```
