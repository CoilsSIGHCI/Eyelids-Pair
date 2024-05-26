//
//  RealtimeGestureView.swift
//  EyelidsPair
//
//  Created by 砚渤 on 2024/5/26.
//

import SwiftUI

struct RealtimeGestureView: View {
    @Binding var gesture: GestureEvent?
    
    let palette: [Color] = [.red, .green, .blue, .orange, .yellow, .purple]
    
    let gestureScreenSize = CGSize(width: 320, height: 240)
    
    // return sf symbol correspoding to the gesture's direction
    var arrowSymbol: String {
        switch gesture?.direction {
        case .upward:
            return "arrowshape.up.fill"
        case .downward:
            return "arrowshape.down.fill"
        case .leftward:
            return "arrowshape.left.fill"
        case .rightward:
            return "arrowshape.right.fill"
        case .forward:
            return "chevron.compact.up"
        case .backward:
            return "chevron.compact.down"
        case .rotationalClockwise:
            return "arrow.clockwise"
        case .rotationalCounterclockwise:
            return "arrow.counterclockwise"
        case .zoomIn:
            return "arrow.down.backward.and.arrow.up.forward"
        case .zoomOut:
            return "arrow.up.forward.and.arrow.down.backward"
        default:
            return "circle"
        }
    }
    
    
    var body: some View {
            ZStack {
                if let gesture = gesture {
                    Image(systemName: arrowSymbol)
                        .scaleEffect(5)
                        .foregroundStyle(palette[gesture.gesture % palette.count])
                        .frame(width: 30, height: 30)
                        .animation(.easeInOut(duration: 0.1), value: gesture)
                        .shadow(color: palette[gesture.gesture % palette.count].opacity(0.5), radius: 4)
                }
                Spacer()
            }
            // full width
            .frame(width: 300, height: 200)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.white.gradient)
            }
            .padding()
            .shadow(radius: 2)
    }
}

#Preview {
//    RealtimeGestureView(gesture: .constant(nil))
    RealtimeGestureView(gesture: .constant(GestureEvent(gesture: 0, direction: .upward, confidence: 0.9)))
}
