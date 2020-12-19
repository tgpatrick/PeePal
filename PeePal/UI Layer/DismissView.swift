//
//  DismissView.swift
//  PeePal
//
//  Created by Thomas Patrick on 11/24/20.


import SwiftUI

struct DismissView: ViewModifier {
    @ObservedObject var vm: ViewModel
    
    @GestureState private var dragOffset = CGSize.zero
    
    func body(content: Content) -> some View {
        ZStack {
            Color.gray
                .opacity(0.00001)
                .edgesIgnoringSafeArea(.all)
                .padding(EdgeInsets(top: 50, leading: 0, bottom: 100, trailing: 0))
                .onTapGesture {
                    self.vm.clearScreen()
                }
                .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                            .onChanged({ _ in
                                self.vm.clearScreen()
                            })
                            .onEnded({ value in
                                withAnimation {
                                    self.vm.region.center.latitude += Double(value.translation.height) * 0.000025
                                    self.vm.region.center.longitude -= Double(value.translation.width) * 0.000025
                                }
                            })
                )
            content
        }
    }
}

extension View {
    func dismissOnOutsideTap(viewModel: ViewModel) -> some View {
        return self.modifier(DismissView(vm: viewModel))
    }
}

struct DismissView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .dismissOnOutsideTap(viewModel: ViewModel())
    }
}
