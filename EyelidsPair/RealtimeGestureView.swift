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
    
    // TODO: change this to the actual screen size of the gesture sensor
    let gestureScreenSize = CGSize(width: 640, height: 480)
    
    func dotPosition(gesture: GestureEvent, frameSize: CGSize) -> CGPoint {
        let x = CGFloat(gesture.x) / gestureScreenSize.width * frameSize.width
        let y = CGFloat(gesture.y) / gestureScreenSize.height * frameSize.height
        return CGPoint(x: x, y: y)
    }
    
    var body: some View {
        // render a canvas with a dot generated at x, y
        GeometryReader { geometry in
            ZStack {
                if let gesture = gesture {
                    Circle()
                        .fill(palette[gesture.gesture])
                        .frame(width: 30, height: 30)
                        .position(dotPosition(gesture: gesture, frameSize: geometry.size))
                        .animation(.easeInOut(duration: 0.1), value: gesture)
                        .shadow(color: palette[gesture.gesture].opacity(0.5), radius: 4)
                }
            }
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.white.gradient)
            }
            .aspectRatio(gestureScreenSize.width / gestureScreenSize.height, contentMode: .fit)
            .padding()
            .shadow(radius: 2)
        }
    }
}

#Preview {
    RealtimeGestureView(gesture: .constant(GestureEvent(x: 210, y: 130, gesture: 0, confidency: 0.8)))
}
