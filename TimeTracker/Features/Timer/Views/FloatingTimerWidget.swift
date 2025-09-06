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

    @State private var position = CGPoint(x: 200, y: 200)
    @State private var isDragging = false
    @State private var dragOffset = CGPoint.zero

    private let widgetWidth: CGFloat = 450
    private let widgetHeight: CGFloat = 120
    private let margin: CGFloat = 20

    var body: some View {
        GeometryReader { geometry in
            TimerWidget(viewModel: self.viewModel)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .scaleEffect(self.isDragging ? 1.05 : 1.0)
                .shadow(radius: self.isDragging ? 8 : 4)
                .position(CGPoint(
                    x: self.position.x + self.dragOffset.x,
                    y: self.position.y + self.dragOffset.y
                ))
                .onAppear {
                    self.setInitialPosition(geometry: geometry)
                }
                .gesture(self.dragGesture)
        }
    }

    private func setInitialPosition(geometry: GeometryProxy) {
        self.position = CGPoint(
            x: geometry.size.width - (self.widgetWidth / 2) - self.margin,
            y: geometry.size.height - (self.widgetHeight / 2) - self.margin
        )
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if !self.isDragging {
                    self.isDragging = true
                }
                self.dragOffset = CGPoint(
                    x: value.translation.width,
                    y: value.translation.height
                )
            }
            .onEnded { value in
                // Commit the drag to position
                self.position.x += value.translation.width
                self.position.y += value.translation.height
                self.dragOffset = .zero
                self.isDragging = false
                self.snapToEdges()
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

        // Calculate safe bounds (prevent going off-screen)
        let minX = (widgetWidth / 2) + self.margin
        let maxX = screenBounds.width - (self.widgetWidth / 2) - self.margin
        let minY = (widgetHeight / 2) + safeArea.top + self.margin
        let maxY = screenBounds.height - (self.widgetHeight / 2) - safeArea.bottom - self.margin

        withAnimation(.easeOut(duration: 0.3)) {
            // First constrain to screen bounds
            self.position.x = max(minX, min(maxX, self.position.x))
            self.position.y = max(minY, min(maxY, self.position.y))

            // Then snap to nearest edge
//            let centerX = screenBounds.width / 2
//            let centerY = screenBounds.height / 2

            // Determine which edge is closest
            let leftDistance = self.position.x - minX
            let rightDistance = maxX - self.position.x
            let topDistance = self.position.y - minY
            let bottomDistance = maxY - self.position.y

            let minHorizontal = min(leftDistance, rightDistance)
            let minVertical = min(topDistance, bottomDistance)

            // Snap to the closest edge type
            if minHorizontal < minVertical {
                // Snap horizontally
                self.position.x = (leftDistance < rightDistance) ? minX : maxX
            } else {
                // Snap vertically
                self.position.y = (topDistance < bottomDistance) ? minY : maxY
            }
        }
    }
}

#Preview {
    let timerViewModel = TimerViewModel(context: PersistenceController.preview.container.viewContext)

    FloatingTimerWidget(viewModel: timerViewModel)
}
