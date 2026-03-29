//
//  ClusterSheetView.swift
//  PeePal
//
//  Created by Thomas Patrick on 3/28/26.
//

import SwiftUI

struct ClusterSheetView: View {
    @Environment(\.dismiss) var dismiss
    
    let cluster: RestroomCluster
    let onSelectItem: ((RestroomCluster) -> Void)?
    let onDismiss: (() -> Void)?
    
    @State private var currentDetent: PresentationDetent = .middle
    
    var body: some View {
        NavigationStack {
            VStack {
                if cluster.isSingle, let restroom = cluster.restrooms.first {
                    RestroomView(restroom: restroom)
                } else {
                    clusterView
                }
            }
            .toolbar {
                Button {
                    dismiss()
                    if let onDismiss {
                        onDismiss()
                    }
                } label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(8)
                        .frame(height: 30)
                        .fontWeight(.heavy)
                }
            }
            .presentationDetents([.low, .middle, .high], selection: $currentDetent)
            .presentationBackgroundInteraction(.enabled(upThrough: .middle))
            .toolbarTitleDisplayMode(.inlineLarge)
        }
    }
    
    var clusterView: some View {
        List(cluster.restrooms) { restroom in
            Button {
                guard let onSelectItem else { return }
                onSelectItem(RestroomCluster(restrooms: [restroom]))
            } label: {
                ListItemView(
                    listItem: restroom
                )
            }
        }
        .listStyle(.plain)
        .navigationTitle("\(cluster.restrooms.count) Restrooms")
    }
}

extension PresentationDetent {
    static let low: PresentationDetent = .height(75)
    static let middle: PresentationDetent = .fraction(0.45)
    static let high: PresentationDetent = .fraction(0.99)
}

#Preview {
    ClusterSheetView(
        cluster: RestroomCluster(restrooms: [
            exampleRestroom,
            exampleRestroom,
            exampleRestroom
        ]),
        onSelectItem: { _ in },
        onDismiss: {}
    )
}
