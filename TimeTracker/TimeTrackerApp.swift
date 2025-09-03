import SwiftUI

@main
struct TimeTrackerApp: App {
  let persistenceController = PersistenceController.shared

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environment(\.managedObjectContext, self.persistenceController.container.viewContext)
    }
  }
}
