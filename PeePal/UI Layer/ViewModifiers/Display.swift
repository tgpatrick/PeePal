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
    func defaultCard(cornerRadius: CGFloat = 15, shadowRadius: CGFloat = 10) -> some View {
        return self
            .background(.thinMaterial)
            .cornerRadius(cornerRadius)
            .adaptiveShadow(radius: shadowRadius)
    }
}

struct PeePalButtonStyle: ButtonStyle {
    var padding: CGFloat = 10
    var radius: CGFloat = 15
    var color: Color = .accentColor
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
        .padding(padding)
        .background(color.opacity(0.5))
        .background(color.opacity(0.5))
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: radius))
        .scaleEffect(configuration.isPressed ? 0.975 : 1)
        .opacity(configuration.isPressed ? 0.5 : 1)
        .shadow(radius: configuration.isPressed ? 0 : 10)
        .animation(.easeOut(duration: configuration.isPressed ? 0 : 0.3), value: configuration.isPressed)
    }
}

struct MapButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) var colorScheme
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .shadow(color: .black, radius: 1.5)
            .foregroundStyle(.accent)
            .frame(width: 45, height: 45, alignment: .center)
            .background(.ultraThickMaterial)
            .clipShape(Circle())
            .scaleEffect(configuration.isPressed ? 0.975 : 1)
            .opacity(configuration.isPressed ? 0.5 : 1)
            .shadow(radius: configuration.isPressed ? 0 : 10)
            .animation(.easeOut(duration: configuration.isPressed ? 0 : 0.3), value: configuration.isPressed)
    }
}

struct NeuPreview: PreviewProvider {
    static var previews: some View {
        ZStack {
            ContentView()
            VStack {
                Text("Hello, World!")
                Button(action: {}, label: {
                    Text("Button")
                })
                .buttonStyle(PeePalButtonStyle())
            }
            .frame(width: 250, height: 250)
            .defaultCard()
        }
    }
}
