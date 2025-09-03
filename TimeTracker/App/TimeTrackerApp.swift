import SwiftUI

@main
struct TimeTrackerApp: App {
  let persistenceController = PersistenceController.shared

  var body: some Scene {
    WindowGroup {
      DashboardView()
        .environment(\.managedObjectContext, self.persistenceController.container.viewContext)
    }
  }
}
