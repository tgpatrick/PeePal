//
//  Display.swift
//  PeePal
//
//  Created by Thomas Patrick on 12/13/20.
//

import SwiftUI

struct AdaptiveShadow: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    @State var radius: CGFloat = 10
    
    func body(content: Content) -> some View {
        if colorScheme == .light {
            return content.shadow(color: .gray, radius: radius)
        } else  {
            return content
                .shadow(color: .black, radius: radius)
        }
    }
}

extension View {
    func adaptiveShadow(radius: CGFloat = 10) -> some View {
        
        return self.modifier(AdaptiveShadow(radius: radius))
    }
}

extension View {
    func PeePalButton(padding: CGFloat = 10, radius: CGFloat = 15) -> some View {
        
        return self
            .padding(padding)
            .background(Color("AccentColor"))
            .cornerRadius(radius)
            .adaptiveShadow()
    }
}

extension View {
    func defaultCard(cornerRadius: CGFloat = 15, shadowRadius: CGFloat = 10) -> some View {
        return self
            .background(Color("AdaptiveBackground"))
            .cornerRadius(cornerRadius)
            .adaptiveShadow(radius: shadowRadius)
    }
}

struct NeuPreview: PreviewProvider {
    static var previews: some View {
        ZStack {
            ContentView(sharedModel: searchModel)
                .onAppear(perform: {
                    searchModel.showTutorial = false
                })
            VStack {
                Text("Hello, World!")
                Button(action: {}, label: {
                    Text("Button")
                        .PeePalButton()
                })
            }
            .frame(width: 250, height: 250)
            .defaultCard()
        }
//        .colorScheme(.dark)
    }
}
