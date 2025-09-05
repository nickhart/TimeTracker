//
//  FloatingTimerWidget.swift
//  TimeTracker
//
//  Created by Nick Hart on 9/3/25.
//

import CoreData
import SwiftUI

struct FloatingTimerWidget: View {
    @StateObject var viewModel: TimerViewModel

    @State private var position = CGPoint.zero // Will be set in onAppear
    @State private var isDragging = false

    // Widget dimensions for proper snapping
    private let widgetWidth: CGFloat = 450
    private let widgetHeight: CGFloat = 120
    private let margin: CGFloat = 20

    var body: some View {
        GeometryReader { geometry in
            TimerWidget(viewModel: self.viewModel)
                .position(self.position)
                .onAppear {
                    // Lower-right using geometry
                    self.position = CGPoint(
                        x: geometry.size.width - (self.widgetWidth / 2) - self.margin,
                        y: geometry.size.height - (self.widgetHeight / 2) - self.margin
                    )
                }
                .scaleEffect(self.isDragging ? 1.05 : 1.0)
                .shadow(radius: self.isDragging ? 8 : 4)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            self.isDragging = true
                            self.position = value.location
                        }
                        .onEnded { _ in
                            self.isDragging = false
                            self.snapToEdges()
                        }
                )
        }
    }

    private func getSafeAreaInsets() -> UIEdgeInsets {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return .zero
        }
        return window.safeAreaInsets
    }

    private func snapToEdges() {
        let screenBounds = UIScreen.main.bounds
        let safeArea = self.getSafeAreaInsets()

        // Calculate boundaries (center points, accounting for widget size)
        let minX = (widgetWidth / 2) + self.margin
        let maxX = screenBounds.width - (self.widgetWidth / 2) - self.margin
        let minY = (widgetHeight / 2) + safeArea.top + self.margin
        let maxY = screenBounds.height - (self.widgetHeight / 2) - safeArea.bottom - self.margin

        // Snap to closest edge
        let distanceToLeft = abs(position.x - minX)
        let distanceToRight = abs(position.x - maxX)
        let distanceToTop = abs(position.y - minY)
        let distanceToBottom = abs(position.y - maxY)

        let minDistance = min(distanceToLeft, distanceToRight, distanceToTop, distanceToBottom)

        withAnimation(.easeOut(duration: 0.3)) {
            switch minDistance {
            case distanceToLeft:
                self.position.x = minX
            case distanceToRight:
                self.position.x = maxX
            case distanceToTop:
                self.position.y = minY
            case distanceToBottom:
                self.position.y = maxY
            default:
                break
            }
        }
    }
}

#Preview {
    let timerViewModel = TimerViewModel(context: PersistenceController.preview.container.viewContext)

    FloatingTimerWidget(viewModel: timerViewModel)
}
