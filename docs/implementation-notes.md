# Key Implementation Notes

## Timer Service

```swift
class TimerService: ObservableObject {
    @Published private(set) var activeTimer: ActiveTimer?
    private var timer: Timer?
    private var backgroundTaskID: UIBackgroundTaskIdentifier?

    func startTimer(for task: TaskStart) {
        // Store start time
        // Begin Live Activity
        // Schedule local notifications
        // Start display timer
    }

    func stopTimer() -> CompletedTask {
        // Calculate duration
        // Round to billing increment
        // Save to Core Data
        // End Live Activity
        // Cancel notifications
    }
}
```

## Sync Strategy
```swift
class CloudKitSyncService {
    func syncCompletedTasks() {
        // Fetch all tasks where endTime != nil && syncStatus != .synced
        // Push to CloudKit
        // Handle conflicts with "last write wins"
        // Update syncStatus
    }

    func subscribeToChanges() {
        // CKDatabaseSubscription for remote changes
        // Process incoming completed tasks
        // Never sync active timers
    }
}
```

## Next Steps Priority

- Phase 1: Core Data setup with models
- Phase 2: Timer service with local persistence
- Phase 3: Basic UI with timer functionality
- Phase 4: Live Activities integration
- Phase 5: CloudKit sync for completed tasks
- Phase 6: Client/Project management UI
- Phase 7: Reporting and export
- Phase 8: Polish, animations, widgets

