//
//  LiveIndicator.swift
//  TemperatureGenie
//
//  Created by Andrew Donnelly on 15/04/2025.
//

import SwiftUI
import Combine

struct LiveIndicator: View {
    let uLineWidth: CGFloat = 5
    let uZoomFactor: CGFloat = 1.8
    let lineWidth: CGFloat = 4
    let lineHeight: CGFloat = 28

    @State var percent = 0.0
    @State var uScale: CGFloat = 1
    @State var lineScale: CGFloat = 1
    @State var textAlpha = 1.0
    @State var textScale: CGFloat = 1
    @State var rotationdegrees: Double = 180
    @State var foreColor: Color = Color("accent1")
    @State var backColor: Color = Color.clear

    @State var active: Bool = false

    @Binding var fillColor: Color

    var body: some View {
        Circle()
            .fill(fillColor)
            .frame(width: 10, height: 10)
        .scaleEffect(textScale)
        .rotation3DEffect(.degrees(rotationdegrees), axis: (x: 1, y: 0, z: 0))
            .onAppear {
                self.handleAnimations()
        }
    }

    func animateConnecting() {
        active = false
        handleAnimations()
    }

    class Coordinator: NSObject {
        var chatIndicator: LiveIndicator
        init(_ chatIndicator: LiveIndicator) {
            self.chatIndicator = chatIndicator
        }
    }
}

extension Animation {
    func repeatWhileActive(while expression: Bool, autoreverses: Bool = true) -> Animation {
        if expression {
            return self.repeatForever(autoreverses: autoreverses)
        } else {
            return self
        }
    }
}

extension LiveIndicator {

    var uAnimationDuration: Double { return 1.0 }
    var uAnimationDelay: Double { return  0.2 }
    var uExitAnimationDuration: Double { return 0.3 }
    var finalAnimationDuration: Double { return 0.4 }
    var minAnimationInterval: Double { return 0.1 }
    var fadeAnimationDuration: Double { return 0.4 }

    func handleAnimations() {
        runAnimationPart1()
    }

    func runAnimationPart1() {
        withAnimation(.easeIn(duration: uAnimationDuration)) {
            percent = 1
            uScale = 1
            lineScale = 1
            rotationdegrees = 0
        }

        withAnimation(Animation.easeIn(duration: uAnimationDuration)
            .delay(0.0)
            .repeatWhileActive(while: active)
        ) {
            textAlpha = 1.0
            rotationdegrees = 360.0
        }

        let deadline: DispatchTime = .now() + uAnimationDuration + uAnimationDelay
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            withAnimation(.easeOut(duration: self.uExitAnimationDuration)) {
                self.uScale = 0
                self.lineScale = 0
            }
        }
    }
}

struct ChatIndicator_Previews: PreviewProvider {
    static var previews: some View {
        LiveIndicator(fillColor: .constant(.red))
    }
}
