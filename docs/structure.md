# Directory Structure & Files

## Feature-Based Architecture

This structure balances organization with simplicity, avoiding over-engineering while maintaining clean separation of concerns.

```
TimeTracker/
├── App/
│   ├── TimeTrackerApp.swift
│   └── Configuration/
│       └── AppConfiguration.swift
│
├── Core/
│   ├── Data/
│   │   ├── PersistenceController.swift
│   │   ├── TimeTracker.xcdatamodeld
│   │   └── Extensions/
│   │       ├── Client+CoreData.swift
│   │       ├── Project+CoreData.swift  
│   │       ├── Task+CoreData.swift
│   │       └── Settings+CoreData.swift
│   │
│   ├── Services/
│   │   ├── TimerService.swift
│   │   ├── CloudKitSyncService.swift
│   │   ├── NotificationService.swift
│   │   └── LiveActivityService.swift
│   │
│   ├── StoreKit/
│   │   ├── StoreKitManager.swift
│   │   ├── PremiumFeatureManager.swift
│   │   ├── PurchaseValidator.swift
│   │   └── ProductIdentifiers.swift
│   │
│   └── Extensions/
│       ├── Decimal+Currency.swift
│       ├── Date+Formatting.swift
│       └── TimeInterval+Display.swift
│
├── Features/
│   ├── Timer/
│   │   ├── Views/
│   │   │   ├── TimerView.swift
│   │   │   ├── TimerControlView.swift
│   │   │   └── ActiveTimerWidget.swift
│   │   ├── ViewModels/
│   │   │   ├── TimerViewModel.swift
│   │   │   └── ActiveTimerViewModel.swift
│   │   └── Models/
│   │       └── ActiveTimer.swift
│   │
│   ├── Dashboard/
│   │   ├── Views/
│   │   │   ├── DashboardView.swift
│   │   │   ├── RecentEntriesView.swift
│   │   │   └── QuickStatsView.swift
│   │   └── ViewModels/
│   │       └── DashboardViewModel.swift
│   │
│   ├── Clients/
│   │   ├── Views/
│   │   │   ├── ClientsListView.swift
│   │   │   ├── ClientDetailView.swift
│   │   │   ├── ClientRowView.swift
│   │   │   └── EditClientView.swift
│   │   └── ViewModels/
│   │       ├── ClientsListViewModel.swift
│   │       └── ClientDetailViewModel.swift
│   │
│   ├── Projects/
│   │   ├── Views/
│   │   │   ├── ProjectsListView.swift
│   │   │   ├── ProjectDetailView.swift
│   │   │   └── EditProjectView.swift
│   │   └── ViewModels/
│   │       ├── ProjectsListViewModel.swift
│   │       └── ProjectDetailViewModel.swift
│   │
│   ├── TimeEntries/
│   │   ├── Views/
│   │   │   ├── TimeEntriesListView.swift
│   │   │   ├── TimeEntryDetailView.swift
│   │   │   └── TimeEntryRowView.swift
│   │   └── ViewModels/
│   │       ├── TimeEntriesListViewModel.swift
│   │       └── TimeEntryDetailViewModel.swift
│   │
│   ├── Reports/
│   │   ├── Views/
│   │   │   ├── ReportsView.swift
│   │   │   ├── ReportFilterView.swift
│   │   │   └── ReportExportView.swift
│   │   └── ViewModels/
│   │       └── ReportsViewModel.swift
│   │
│   ├── Settings/
│   │   ├── Views/
│   │   │   ├── SettingsView.swift
│   │   │   └── DefaultsSettingsView.swift
│   │   └── ViewModels/
│   │       └── SettingsViewModel.swift
│   │
│   └── Premium/
│       ├── Views/
│       │   ├── PaywallView.swift
│       │   ├── PremiumFeatureCard.swift
│       │   ├── PurchaseButton.swift
│       │   ├── RestorePurchasesView.swift
│       │   └── SubscriptionStatusView.swift
│       └── ViewModels/
│           └── PaywallViewModel.swift
│
├── Shared/
│   ├── Components/
│   │   ├── CurrencyTextField.swift
│   │   ├── IncrementPicker.swift
│   │   └── LoadingView.swift
│   │
│   ├── Styles/
│   │   ├── AppStyles.swift
│   │   └── ColorScheme.swift
│   │
│   └── Utilities/
│       ├── BillingCalculator.swift
│       ├── CSVExporter.swift
│       └── HapticFeedback.swift
│
├── Resources/
│   ├── Assets.xcassets
│   ├── Localizable.strings
│   └── Info.plist
│
└── LiveActivity/
    ├── TimerActivityAttributes.swift
    └── TimerActivityWidget.swift
```

## Test Structure

Test structure mirrors the source code organization for easy navigation:

### Test Naming Convention
- **Extension files**: `Type+Category.swift` → **Test files**: `TypeCategoryTests.swift`  
- **Example**: `Client+CoreData.swift` → `ClientCoreDataTests.swift`
- **Class name matches file name**: `ClientCoreDataTests`
- **No "+" in test file names** - follows industry best practices

```
TimeTrackerTests/
├── Core/
│   ├── Data/
│   │   ├── PersistenceControllerTests.swift
│   │   └── Models/
│   │       └── CoreDataModelTests.swift
│   │
│   ├── Services/
│   │   ├── TimerServiceTests.swift
│   │   ├── CloudKitSyncServiceTests.swift
│   │   └── NotificationServiceTests.swift
│   │
│   ├── StoreKit/
│   │   ├── StoreKitManagerTests.swift
│   │   ├── PremiumFeatureManagerTests.swift
│   │   └── PurchaseValidatorTests.swift
│   │
│   └── Extensions/
│       ├── Date+FormattingTests.swift
│       └── TimeInterval+DisplayTests.swift
│
├── Features/
│   ├── Timer/
│   │   ├── ViewModels/
│   │   │   └── TimerViewModelTests.swift
│   │   └── Models/
│   │       └── ActiveTimerTests.swift
│   │
│   ├── Dashboard/
│   │   └── ViewModels/
│   │       └── DashboardViewModelTests.swift
│   │
│   ├── Clients/
│   │   └── ViewModels/
│   │       ├── ClientsListViewModelTests.swift
│   │       └── ClientDetailViewModelTests.swift
│   │
│   ├── Projects/
│   │   └── ViewModels/
│   │       └── ProjectsListViewModelTests.swift
│   │
│   ├── TimeEntries/
│   │   └── ViewModels/
│   │       └── TimeEntriesListViewModelTests.swift
│   │
│   ├── Reports/
│   │   └── ViewModels/
│   │       └── ReportsViewModelTests.swift
│   │
│   ├── Settings/
│   │   └── ViewModels/
│   │       └── SettingsViewModelTests.swift
│   │
│   └── Premium/
│       └── ViewModels/
│           └── PaywallViewModelTests.swift
│
├── Shared/
│   └── Utilities/
│       ├── BillingCalculatorTests.swift
│       └── CSVExporterTests.swift
│
└── Helpers/
    ├── CoreDataTestStack.swift
    ├── TestData.swift
    └── MockServices.swift
```

## Architecture Benefits

- **🎯 Feature-focused**: Related code grouped together
- **🔍 Easy navigation**: Mirror structure in tests
- **📦 Clean separation**: Core logic separate from UI
- **🧪 Testable**: Clear boundaries for unit testing
- **📈 Scalable**: Add features without restructuring
- **🤝 Team-friendly**: Intuitive organization
