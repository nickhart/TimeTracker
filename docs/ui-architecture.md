# UI Architecture & Key Views
## Hierarchical Navigation Structure

### Navigation Hierarchy
```text
Root Dashboard (Overview)
├── Client1
│   ├── Client Dashboard
│   ├── Project1
│   │   ├── Project Dashboard  
│   │   └── Tasks
│   ├── Project2
│   │   ├── Project Dashboard
│   │   └── Tasks
│   ├── Unassigned Tasks
│   └── Client Settings
├── Client2
│   └── [same structure]
└── User Settings
```

### TimeTrackerApp Structure (Device-Adaptive)
```swift
struct TimeTrackerApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            if UIDevice.isPhone {
                // iPhone: Static timer at bottom
                VStack(spacing: 0) {
                    NavigationSplitView {
                        SidebarView()
                    } detail: {
                        RootDashboardView()
                    }
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    
                    StaticTimerWidget()
                }
            } else {
                // iPad: Floating draggable timer
                ZStack {
                    NavigationSplitView {
                        SidebarView() 
                    } detail: {
                        RootDashboardView()
                    }
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    
                    FloatingTimerWidget()
                        .zIndex(1) // Ensure timer stays on top
                }
            }
        }
    }
}
```

### Device Detection Extension
```swift
extension UIDevice {
    static var isPhone: Bool {
        Self.current.userInterfaceIdiom == .phone
    }
    
    static var isPad: Bool {
        Self.current.userInterfaceIdiom == .pad
    }
}
```

## Timer Widget Implementations

### StaticTimerWidget (iPhone)
```swift
// Fixed bottom position - thumb-friendly iPhone design
struct StaticTimerWidget: View {
    @ObservedObject var viewModel: TimerViewModel
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            if isExpanded {
                expandedControls
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            compactBar
        }
        .background(.regularMaterial)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(.separator)
                .frame(height: 0.5)
        }
    }
    
    private var compactBar: some View {
        HStack {
            Button {
                viewModel.showTaskCreation()
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.currentTaskName ?? "No active task")
                    .font(.caption)
                    .lineLimit(1)
                
                if let clientName = viewModel.clientName {
                    Text(clientName)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Text(viewModel.formattedTime)
                .font(.system(.subheadline, design: .monospaced))
                .fontWeight(.medium)

            Button(viewModel.isRunning ? "Stop" : "Start") {
                if viewModel.isRunning {
                    viewModel.stopTimer()
                } else {
                    viewModel.startQuickTimer()
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .onTapGesture {
            withAnimation(.spring()) {
                isExpanded.toggle()
            }
        }
    }
    
    private var expandedControls: some View {
        // Additional controls when expanded
        HStack {
            Button("New Task") {
                viewModel.createNewTask()
            }
            .buttonStyle(.bordered)
            
            Spacer()
            
            Button("History") {
                viewModel.showHistory()
            }
            .buttonStyle(.bordered)
        }
        .padding(.horizontal)
        .padding(.bottom, 12)
    }
}
```

### FloatingTimerWidget (iPad)  
```swift
// Draggable overlay with drag handle - iPad optimized
struct FloatingTimerWidget: View {
    @ObservedObject var viewModel: TimerViewModel
    @State private var isExpanded = false
    @State private var dragPosition = CGPoint(x: 300, y: 100) // Default position
    @State private var dragOffset = CGSize.zero
    
    var body: some View {
        Group {
            if isExpanded {
                expandedView
            } else {
                compactView
            }
        }
        .position(x: dragPosition.x + dragOffset.width, 
                 y: dragPosition.y + dragOffset.height)
        .onTapGesture {
            withAnimation(.spring()) {
                isExpanded.toggle()
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation
                }
                .onEnded { value in
                    // Update final position and reset offset
                    dragPosition.x += value.translation.x
                    dragPosition.y += value.translation.y
                    dragOffset = .zero
                    
                    // Optional: Snap to edges or safe boundaries
                    snapToEdgeIfNeeded()
                }
        )
    }
    
    private var compactView: some View {
        HStack(spacing: 8) {
            // Drag handle (subtle grip indicator)
            Image(systemName: "grip.dots.horizontal")
                .font(.caption2)
                .foregroundStyle(.secondary)
            
            // Status indicator  
            Circle()
                .fill(viewModel.isRunning ? Color.green : Color.gray)
                .frame(width: 8, height: 8)
                .scaleEffect(viewModel.isRunning ? animationAmount : 1)
                .animation(viewModel.isRunning ? .easeInOut(duration: 1).repeatForever() : .none)
            
            Text(viewModel.formattedTime)
                .font(.system(.caption, design: .monospaced))
                .fontWeight(.medium)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.regularMaterial, in: Capsule())
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    private var expandedView: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with drag handle
            HStack {
                Image(systemName: "grip.dots.horizontal")
                    .font(.caption2) 
                    .foregroundStyle(.secondary)
                
                Text(viewModel.currentTaskName ?? "No active task")
                    .font(.headline)
                    .lineLimit(1)
                
                Spacer()
                
                Button {
                    viewModel.showTaskCreation()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                }
            }
            
            // Client info
            if let clientName = viewModel.clientName {
                Text(clientName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            // Time display and controls
            HStack {
                VStack(alignment: .leading) {
                    Text("Duration")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(viewModel.formattedTime)
                        .font(.system(.title2, design: .monospaced))
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                VStack(spacing: 8) {
                    Button(viewModel.isRunning ? "Stop" : "Start") {
                        if viewModel.isRunning {
                            viewModel.stopTimer()
                        } else {
                            viewModel.startQuickTimer()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.regular)
                    
                    if !viewModel.isRunning {
                        Button("New Task") {
                            viewModel.createNewTask()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.15), radius: 16, x: 0, y: 8)
        .frame(width: 280, height: 140) // iPhone-sized widget
    }
    
    private func snapToEdgeIfNeeded() {
        // Optional: Implement edge snapping logic
        // Could snap to screen edges, avoid notches, etc.
        
        // Example: Keep within safe bounds
        let screenBounds = UIScreen.main.bounds
        let safeMargin: CGFloat = 20
        
        dragPosition.x = max(safeMargin, min(dragPosition.x, screenBounds.width - safeMargin))
        dragPosition.y = max(safeMargin, min(dragPosition.y, screenBounds.height - safeMargin))
    }
}
```
## Root Dashboard View
```swift
struct RootDashboardView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Client.name, ascending: true)]
    ) private var clients: FetchedResults<Client>
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Quick stats overview
                StatsOverviewSection()
                
                // Recent tasks for quick restart
                RecentTasksSection()
                
                // Active projects
                ActiveProjectsSection()
                
                // Clients list
                ClientsSection(clients: clients)
            }
            .padding()
        }
        .navigationTitle("TimeTracker")
        .navigationDestination(for: Client.self) { client in
            ClientDashboardView(client: client)
        }
    }
}
```

## Context-Aware Creation
```swift
struct ContextualCreateButton: View {
    @Environment(\.navigationPath) private var navigationPath
    
    var body: some View {
        Button {
            // Context determines what to create:
            // Root: Create Client
            // Client view: Create Project  
            // Project view: Create Task
            handleContextualCreate()
        } label: {
            Image(systemName: "plus")
        }
    }
    
    private func handleContextualCreate() {
        // Implementation based on current navigation context
    }
}
```

## Navigation Views

### Client Dashboard
```swift
struct ClientDashboardView: View {
    let client: Client
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ClientStatsSection(client: client)
                ProjectsSection(client: client) 
                UnassignedTasksSection(client: client)
            }
        }
        .navigationTitle(client.name ?? "Client")
        .navigationDestination(for: Project.self) { project in
            ProjectDashboardView(project: project)
        }
    }
}
```

### Project Dashboard  
```swift
struct ProjectDashboardView: View {
    let project: Project
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ProjectStatsSection(project: project)
                TasksSection(project: project)
            }
        }
        .navigationTitle(project.name ?? "Project")
    }
}
```

## Key Design Principles

### 1. Draggable Floating Timer Design
- **User positioning** - drag handle allows custom placement anywhere on screen
- **iPhone-sized consistency** - 280x140px expanded, familiar form factor
- **Expandable interface** - tap to reveal full controls with professional layout
- **Smart boundaries** - snaps to safe areas, avoids notches and edges
- **Visual hierarchy** - elevated shadows and materials, stays above all content
- **Persistent state** - remembers user's preferred position across sessions

### 2. Context-Aware Actions
- **Navbar +** creates appropriate entity for current view level
- **Smart defaults** - inherit client/project from current context  
- **Progressive disclosure** - start simple, add details later

### 3. Natural Information Hierarchy
- **Drill down** follows data relationships
- **Dashboard at each level** - stats and quick actions
- **Consistent patterns** - similar layouts at each level

### 4. iPad-First Design
- **NavigationSplitView** - proper sidebar/detail layout from day one
- **Floating timer** - minimal screen real estate usage
- **Expandable widget** - tap to reveal full controls
- **Automatic iPhone adaptation** - NavigationSplitView becomes NavigationStack
- **Contextual toolbars** - actions relevant to current view

## File Structure & Classes

### Core Views
```
TimeTracker/App/
├── TimeTrackerApp.swift           // App entry point with NavigationSplitView
└── SidebarView.swift              // Adaptive sidebar navigation

TimeTracker/Features/Dashboard/Views/
├── RootDashboardView.swift        // Main dashboard with overview
├── StatsOverviewSection.swift     // Today's stats cards
├── RecentTasksSection.swift       // Quick restart section
├── ActiveProjectsSection.swift    // Active projects list
└── ClientsSection.swift           // Clients list

TimeTracker/Features/Clients/Views/
├── ClientDashboardView.swift      // Client-specific dashboard
├── ClientStatsSection.swift       // Client stats
├── ProjectsSection.swift          // Client's projects list
└── UnassignedTasksSection.swift   // Tasks without projects

TimeTracker/Features/Projects/Views/
├── ProjectDashboardView.swift     // Project-specific dashboard
├── ProjectStatsSection.swift      // Project stats
└── TasksSection.swift             // Project's tasks list

TimeTracker/Features/Timer/Views/
├── FloatingTimerWidget.swift      // Compact floating timer
└── TimerViewModel.swift           // Timer state management
```

### Shared Components
```
TimeTracker/Shared/Components/
├── ContextualCreateButton.swift   // Navbar + button
├── StatCard.swift                 // Reusable stat display
└── TaskRow.swift                  // Consistent task display

TimeTracker/Features/Settings/Views/
├── SettingsView.swift             // User settings
├── ClientSettingsView.swift       // Client-specific settings
└── ProjectSettingsView.swift      // Project-specific settings
```

### ViewModels & Services
```
TimeTracker/Core/Services/
├── ClientService.swift            // Client CRUD operations
├── ProjectService.swift           // Project CRUD operations
├── TaskService.swift              // Task CRUD operations
└── TimerService.swift             // Timer management

TimeTracker/Features/Dashboard/ViewModels/
├── RootDashboardViewModel.swift   // Dashboard state
└── StatsViewModel.swift           // Statistics calculations

TimeTracker/Features/Timer/ViewModels/
└── ActiveTimerViewModel.swift     // Timer widget state

TimeTracker/Core/StoreKit/
├── StoreKitManager.swift           // StoreKit 2 integration
├── PremiumFeatureManager.swift     // Feature flag management  
├── PurchaseValidator.swift         // Receipt validation
└── ProductIdentifiers.swift       // IAP product constants

TimeTracker/Features/Premium/Views/
├── PaywallView.swift              // Main subscription paywall
├── PremiumFeatureCard.swift       // Feature highlight component
├── PurchaseButton.swift           // StoreKit purchase button
├── RestorePurchasesView.swift     // Purchase restoration
└── SubscriptionStatusView.swift   // Current subscription display
```

## Premium Feature Integration

### Feature Gating Pattern
```swift
// Consistent gating across all views  
struct AdvancedReportsSection: View {
    @StateObject private var premiumManager = PremiumFeatureManager.shared
    
    var body: some View {
        if premiumManager.canAccessAdvancedReports {
            FullReportsView()
        } else {
            PremiumFeatureTeaser(
                feature: .advancedReports,
                previewContent: BlurredReportsPreview()
            )
        }
    }
}
```

### Paywall Placement Strategy
```swift
// Strategic paywall triggers throughout the app
enum PaywallTrigger {
    case advancedReportsAccess    // After viewing basic reports
    case invoiceGeneration        // When trying to generate invoice
    case customizationAttempt     // Accessing themes/customization
    case historicalDataLimit      // After 30 days of usage
    case bulkTimeEntry           // When entering multiple entries
}
```

### Premium Navigation Flow
```swift
// NavigationSplitView with premium considerations
NavigationSplitView {
    SidebarView()
        .overlay(alignment: .bottom) {
            if !premiumManager.isPremium {
                UpgradePromptBanner()
            }
        }
} detail: {
    selectedView
        .sheet(isPresented: $showPaywall) {
            PaywallView(trigger: currentPaywallTrigger)
        }
}
```

### Premium Feature UI Patterns

#### Soft Paywalls (Encourage Upgrades)
```swift
struct ReportsSection: View {
    var body: some View {
        VStack {
            BasicReportsView()
            
            if !PremiumFeatureManager.canAccessAdvancedReports() {
                PremiumFeatureCard(
                    title: "Advanced Analytics",
                    description: "Unlock detailed time patterns and productivity insights",
                    feature: .advancedReports
                )
            }
        }
    }
}
```

#### Hard Paywalls (Block Access)
```swift
struct InvoiceGenerationView: View {
    var body: some View {
        if PremiumFeatureManager.canGenerateInvoices() {
            InvoiceBuilderView()
        } else {
            PaywallView(
                feature: .invoiceGeneration,
                title: "Professional Invoicing",
                benefits: [
                    "PDF invoice generation",
                    "Custom branding",
                    "Automatic calculations",
                    "Professional templates"
                ]
            )
        }
    }
}
```

#### Premium Feature Badges
```swift
struct FeatureRow: View {
    let title: String
    let isPremium: Bool
    
    var body: some View {
        HStack {
            Text(title)
            if isPremium {
                Text("PRO")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.orange.gradient)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
        }
    }
}
```
