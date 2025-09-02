# Directory Structure & Files

```
TimeTracker/
├── App/
│   ├── TimeTrackerApp.swift
│   ├── AppDelegate.swift
│   └── Configuration/
│       ├── AppConstants.swift
│       └── AppConfiguration.swift
│
├── Core/
│   ├── Models/
│   │   ├── TimeTracker.xcdatamodeld
│   │   ├── Client+CoreDataClass.swift
│   │   ├── Client+CoreDataProperties.swift
│   │   ├── Project+CoreDataClass.swift
│   │   ├── Task+CoreDataClass.swift
│   │   └── Settings+CoreDataClass.swift
│   │
│   ├── Services/
│   │   ├── TimerService.swift
│   │   ├── CloudKitSyncService.swift
│   │   ├── NotificationService.swift
│   │   ├── BillingCalculationService.swift
│   │   └── LiveActivityService.swift
│   │
│   ├── Repositories/
│   │   ├── Protocol/
│   │   │   ├── ClientRepositoryProtocol.swift
│   │   │   ├── ProjectRepositoryProtocol.swift
│   │   │   └── TaskRepositoryProtocol.swift
│   │   └── CoreData/
│   │       ├── CoreDataStack.swift
│   │       ├── ClientRepository.swift
│   │       ├── ProjectRepository.swift
│   │       └── TaskRepository.swift
│   │
│   └── Extensions/
│       ├── Decimal+Currency.swift
│       ├── Date+Formatting.swift
│       └── TimeInterval+Display.swift
│
├── Features/
│   ├── Timer/
│   │   ├── ViewModels/
│   │   │   ├── TimerViewModel.swift
│   │   │   └── ActiveTimerViewModel.swift
│   │   ├── Views/
│   │   │   ├── TimerView.swift
│   │   │   ├── TimerControlView.swift
│   │   │   ├── ActiveTimerWidget.swift
│   │   │   └── TimerButton.swift
│   │   └── Models/
│   │       └── ActiveTimer.swift
│   │
│   ├── Clients/
│   │   ├── ViewModels/
│   │   │   ├── ClientsListViewModel.swift
│   │   │   └── ClientDetailViewModel.swift
│   │   └── Views/
│   │       ├── ClientsListView.swift
│   │       ├── ClientDetailView.swift
│   │       ├── ClientRowView.swift
│   │       └── EditClientView.swift
│   │
│   ├── Projects/
│   │   ├── ViewModels/
│   │   │   ├── ProjectsListViewModel.swift
│   │   │   └── ProjectDetailViewModel.swift
│   │   └── Views/
│   │       ├── ProjectsListView.swift
│   │       ├── ProjectDetailView.swift
│   │       └── EditProjectView.swift
│   │
│   ├── Tasks/
│   │   ├── ViewModels/
│   │   │   ├── TasksListViewModel.swift
│   │   │   └── TaskDetailViewModel.swift
│   │   └── Views/
│   │       ├── TasksListView.swift
│   │       ├── TaskDetailView.swift
│   │       └── TaskRowView.swift
│   │
│   ├── Reports/
│   │   ├── ViewModels/
│   │   │   └── ReportsViewModel.swift
│   │   └── Views/
│   │       ├── ReportsView.swift
│   │       ├── ReportFilterView.swift
│   │       └── ReportExportView.swift
│   │
│   └── Settings/
│       ├── ViewModels/
│       │   └── SettingsViewModel.swift
│       └── Views/
│           ├── SettingsView.swift
│           └── DefaultsSettingsView.swift
│
├── Shared/
│   ├── Views/
│   │   ├── Components/
│   │   │   ├── CurrencyTextField.swift
│   │   │   ├── IncrementPicker.swift
│   │   │   └── LoadingView.swift
│   │   └── Modifiers/
│   │       ├── CardStyle.swift
│   │       └── ErrorAlert.swift
│   │
│   ├── ViewModels/
│   │   └── BaseViewModel.swift
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

```
TimeTrackerTests/
├── Core/
│   ├── Services/
│   │   ├── TimerServiceTests.swift
│   │   ├── BillingCalculationServiceTests.swift
│   │   └── CloudKitSyncServiceTests.swift
│   │
│   ├── Repositories/
│   │   ├── Mocks/
│   │   │   ├── MockClientRepository.swift
│   │   │   └── MockCoreDataStack.swift
│   │   ├── ClientRepositoryTests.swift
│   │   └── TaskRepositoryTests.swift
│   │
│   └── Utilities/
│       └── BillingCalculatorTests.swift
│
├── Features/
│   ├── Timer/
│   │   └── TimerViewModelTests.swift
│   ├── Clients/
│   │   └── ClientsListViewModelTests.swift
│   └── Reports/
│       └── ReportsViewModelTests.swift
│
└── Helpers/
    ├── CoreDataTestStack.swift
    └── TestData.swift
```
