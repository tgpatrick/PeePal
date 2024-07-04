//
//  ContentView.swift
//  PeePal
//
//  Created by Thomas Patrick on 11/10/20.
//
import SwiftUI
import MapKit

struct ContentView: View {
    @State private var viewModel = ContentViewModel()

    var body: some View {
        ZStack {
            Map()
        }
        .task {
            await viewModel.fetchRestrooms()
        }
        .alert("Error", isPresented: Binding<Bool>(
            get: { viewModel.error != nil },
            set: { if !$0 { viewModel.error = nil } }
        ), actions: {
            Button("OK") { viewModel.error = nil }
        }, message: {
            Text(viewModel.error?.localizedDescription ?? "An unknown error occurred")
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
