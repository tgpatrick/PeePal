//
//  AddView.swift
//  PeePal
//
//  Created by Thomas Patrick on 12/13/20.
//

import SwiftUI

struct AddView: View {
    @ObservedObject var sm: SharedModel
    
    var body: some View {
        ZStack {
            VStack(alignment: .center) {
                Text("It looks like we don't know of any restrooms near here.")
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)
                    .padding(.top, 20)
                Link(destination: URL(string: "https://www.refugerestrooms.org/restrooms/new")!) {
                    HStack {
                        Image(systemName: "plus")
                            .foregroundColor(.black)
                        Text("Add one")
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                    }
                    .PeePalButton(padding: 8, radius: 15)
                }
                .padding()
            }
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        sm.clearScreen()
                    }) {
                        Image(systemName: "multiply.circle.fill")
                            .scaleEffect(CGSize(width: 1.5, height: 1.5))
                            .foregroundColor(.gray)
                            .opacity(0.5)
                    }
                    .padding()
                }
                Spacer()
            }
        }
        .frame(width: 250, height: 225)
        .defaultCard()
    }
}
