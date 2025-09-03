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
├── projects: [Project] (one-to-many)
└── tasks: [Task] (one-to-many, direct relationship)

Project
├── id: UUID
├── name: String
├── hourlyRate: Decimal? (overrides client rate if set)
├── billingIncrement: Int16? (overrides client if set)
├── isActive: Bool
├── createdAt: Date
├── modifiedAt: Date
├── client: Client (many-to-one)
└── tasks: [Task] (one-to-many)

Task
├── id: UUID
├── name: String? (optional for quick creation)
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
├── client: Client (many-to-one, required)
└── project: Project? (many-to-one, optional)

Settings (single record)
├── defaultHourlyRate: Decimal
├── defaultBillingIncrement: Int16
├── autoPauseEnabled: Bool
├── autoPauseMinutes: Int16
└── notificationSettings: Data (JSON)
```

## Key Design Decisions

### Direct Client-Task Relationship
- **Every task belongs to a client** (required relationship)
- **Project assignment is optional** - enables quick task creation
- **Clear ownership model**: Client owns the task, project is just organization
- **Flexible workflow**: Start timing immediately, organize into projects later

### Computed ID Properties
- No stored `clientID` or `projectID` fields - use relationships instead
- Access via computed properties to avoid data inconsistency:
```swift
extension Project {
    var clientID: UUID? { client?.id }
}

extension Task {
    var projectID: UUID? { project?.id }
    var clientID: UUID { client.id }  // Always available
}
```

## Core Data Relationship Configuration

### Delete Rules
| From | To | Relationship | Delete Rule | Rationale |
|------|----|--------------|--------------|-----------|
| Client | projects | One-to-Many | **Cascade** | Delete client's projects when client is deleted |
| Client | tasks | One-to-Many | **Cascade** | Delete client's tasks when client is deleted |
| Project | client | Many-to-One | **Nullify** | Project can't exist without client (but handled by cascade above) |
| Project | tasks | One-to-Many | **Nullify** | Tasks remain when project deleted, just lose project assignment |
| Task | client | Many-to-One | **Nullify** | Client cascade deletion handles task cleanup |
| Task | project | Many-to-One | **Nullify** | Task can exist without project assignment |

### Data Consistency Rules
1. **Task-Project-Client Consistency**: If `task.project != nil`, then `task.client` must equal `task.project.client`
2. **Validation**: Implement in Core Data validation methods or business logic layer
3. **Assignment Logic**: When assigning task to project, automatically set task.client = project.client

## Sync Considerations

- Only Task entities with endTime != nil will sync
- Add syncStatus enum: .local, .syncing, .synced, .conflict
- Add lastSyncedAt: Date? to track sync state
- Current active timer stored in UserDefaults/memory, not Core Data

## Implementation Notes

### Quick Task Creation Workflow
```swift
// 1. Start timer immediately
let task = Task(context: context)
task.client = selectedClient  // Required
task.startTime = Date()
// task.project remains nil

// 2. Later: optionally assign to project
task.project = selectedProject
// Validation: ensure task.client == selectedProject.client
```

### Data Queries
```swift
// All tasks for a client (includes both project and non-project tasks)
client.tasks

// Tasks for a specific project
project.tasks

// Client's unassigned tasks (not in any project)
client.tasks.filter { $0.project == nil }
```
