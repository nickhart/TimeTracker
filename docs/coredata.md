# Core Data Model Design
## Entities & Relationships

```text
// Core Entities
Client
├── id: UUID
├── name: String
├── hourlyRate: Decimal
├── billingIncrement: Int16 (in minutes: 1, 5, 15, 30, 60)
├── notes: String?
├── createdAt: Date
├── modifiedAt: Date
└── projects: [Project] (one-to-many)

Project
├── id: UUID
├── name: String
├── clientID: UUID
├── hourlyRate: Decimal? (overrides client rate if set)
├── billingIncrement: Int16? (overrides client if set)
├── isActive: Bool
├── createdAt: Date
├── modifiedAt: Date
├── client: Client (many-to-one)
└── tasks: [Task] (one-to-many)

Task
├── id: UUID
├── name: String
├── projectID: UUID
├── startTime: Date
├── endTime: Date?
├── duration: Int64 (cached, in seconds)
├── hourlyRate: Decimal? (overrides project/client if set)
├── notes: String?
├── isBilled: Bool
├── billedAmount: Decimal?
├── billedDate: Date?
├── createdAt: Date
├── modifiedAt: Date
└── project: Project (many-to-one)

Settings (single record)
├── defaultHourlyRate: Decimal
├── defaultBillingIncrement: Int16
├── autoPauseEnabled: Bool
├── autoPauseMinutes: Int16
└── notificationSettings: Data (JSON)
```

## Sync Considerations

- Only Task entities with endTime != nil will sync
- Add syncStatus enum: .local, .syncing, .synced, .conflict
- Add lastSyncedAt: Date? to track sync state
- Current active timer stored in UserDefaults/memory, not Core Data
