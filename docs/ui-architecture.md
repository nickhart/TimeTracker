# UI Architecture & Key Views
## Main Tab Structure

```swift
TabView {
    TimerView()
        .tabItem { Label("Timer", systemImage: "timer") }

    ClientsListView()
        .tabItem { Label("Clients", systemImage: "person.2") }

    TasksListView()
        .tabItem { Label("Tasks", systemImage: "list.bullet") }

    ReportsView()
        .tabItem { Label("Reports", systemImage: "chart.bar") }

    SettingsView()
        .tabItem { Label("Settings", systemImage: "gear") }
}
```

## Active Timer Widget (Omnipresent)
```swift
// Shows at top of screen when timer is running
struct ActiveTimerWidget: View {
    @ObservedObject var viewModel: ActiveTimerViewModel

    var body: some View {
        HStack {
            // Animated pulsing dot
            Circle()
                .fill(Color.green)
                .frame(width: 8, height: 8)
                .scaleEffect(animationAmount)
                .animation(.easeInOut(duration: 1).repeatForever())

            Text(viewModel.currentTaskName)
                .font(.caption)

            Spacer()

            Text(viewModel.formattedTime)
                .font(.system(.caption, design: .monospaced))

            Button("Stop") {
                viewModel.stopTimer()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
        .padding()
        .background(.thinMaterial)
    }
}
```
## Timer View (Main Interface)
```swift
struct TimerView: View {
    // Large, friendly start button
    // Quick project/client selection
    // Recent tasks for quick restart
    // Current session summary
}
```
