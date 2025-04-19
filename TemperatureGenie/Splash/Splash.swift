//
//  Splash.swift
//  TemperatureGenie
//
//  Created by Andrew Donnelly on 01/04/2025.
//

import SwiftUI

struct Splash: View {
    @State var imageAlpha = 0.2
    @State var angle:Double = 360
    @State var opacity:Double = 1
    @State var scale: CGFloat = 3

    var body: some View {
        VStack {
            Spacer()
            HStack { logoImage }
            Spacer()
        }.edgesIgnoringSafeArea(.all)
            .onAppear {
                withAnimation(.linear(duration: 2)) {
                    self.angle = 0
                    self.scale = 1
                    self.opacity = 0
                }
            }
    }

    private var logoImage: some View {
        return AnyView(
            Image("TempGenieLogo")
                .resizable()
                .frame(width: 65, height: 10, alignment: .center)
                .rotation3DEffect(.degrees(angle), axis: (x: 0, y: 1, z: 0))
                .scaleEffect(scale)
                .opacity(opacity)
        )
    }
}

struct AnimatedSplash_Previews: PreviewProvider {
    static var previews: some View {
        Splash()
    }
}
