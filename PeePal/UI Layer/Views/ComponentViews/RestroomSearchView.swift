//
//  RestroomSeachView.swift
//  PeePal
//
//  Created by Thomas Patrick on 11/15/20.
//

import SwiftUI

struct RestroomSearchView: View {
    @ObservedObject var sm: SharedModel
    let restroom: SearchRestroom
    
    init(sharedModel: SharedModel, restroom: SearchRestroom) {
        self.sm = sharedModel
        self.restroom = restroom
    }
    
    var body: some View {
        VStack{
            HStack {
                AnnotationView(restroom: self.sm.appLogic.searchToReal(searchRestroom: restroom), viewModel: sm, contentViewModel: ContentViewModel_Old())
                    .scaleEffect(CGSize(width: 0.4, height: 0.4))
                    .frame(width: 25, height: 25)
                Text(restroom.name ?? "No name")
                    .fontWeight(.bold)
                Spacer()
            }
            HStack(alignment: .top) {
                Text("Address: ")
                    .font(.caption)
                    .fontWeight(.bold)
                VStack(alignment: .leading) {
                    Text(restroom.street ?? "None")
                    .font(.caption)
                    Text(restroom.city ?? "None")
                    .font(.caption)
                    + Text(", ")
                    .font(.caption)
                    + Text(restroom.state ?? "None")
                    .font(.caption)
                }
                Spacer()
            }
            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
        }
        .padding(3)
        .defaultCard(cornerRadius: 5, shadowRadius: 10)
        .onTapGesture {
            self.sm.cvm.showSearch = false
            self.sm.svm.searchText = ""
            withAnimation {
                sm.cvm.showDetail(restroom: sm.appLogic.searchToReal(searchRestroom: restroom))
            }
        }
    }
}

let exampleSearchRoom = SearchRestroom(id: 4, name: "Search Restroom", street: "123 Hello World Ln", city: "Cupertino", state: "California", accessible: true, unisex: true, directions: nil, comment: nil, downvote: 0, upvote: 1, latitude: 1, longitude: 1, changing_table: false)

struct RestroomSearchView_Previews: PreviewProvider {
    static var previews: some View {
        RestroomSearchView(sharedModel: SharedModel(), restroom: exampleSearchRoom)
//        ContentView()
//            .colorScheme(.dark)
    }
}
