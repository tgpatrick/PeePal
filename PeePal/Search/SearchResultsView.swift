//
//  SearchResultsView.swift
//  PeePal
//
//  Created by Thomas Patrick on 3/29/26.
//

import SwiftUI

struct SearchResultsView: View {
    @State var viewModel: SearchViewModel
    
    var body: some View {
        Color(.black)
            .opacity(0.5)
    }
}

#Preview {
    SearchResultsView(viewModel: SearchViewModel())
}
