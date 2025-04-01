//
//  Splash.swift
//  TemperatureGenie
//
//  Created by Andrew Donnelly on 01/04/2025.
//

import SwiftUI

struct Splash: View {
    static var shouldAnimate = true

    @State var showAnimation = false
    @State var imageAlpha = 0.2

    var body: some View {
        let animation = Animation
            .linear(duration: 2.0)
        VStack {
            Spacer()
            HStack { logoImage }
            Spacer()
        }.edgesIgnoringSafeArea(.all)
            .onAppear {
                DispatchQueue.main.async {
                    withAnimation(animation) {
                        imageAlpha = 1.0
                        showAnimation =  true
                    }
                }
            }
    }

    private var logoImage: some View {
        return AnyView(
            Image("TempGenieLogo").resizable().frame(width: 232, height: 30, alignment: .center)
        )
    }
}

struct AnimatedSplash_Previews: PreviewProvider {
    static var previews: some View {
        Splash()
    }
}
