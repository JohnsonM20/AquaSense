//
//  InformationContainerView.swift
//  LuckyFinds
//
//  Created by Matthew Johnson on 12/24/21.
//

import SwiftUI

struct InformationContainerView: View {
    var body: some View {
        VStack(alignment: .leading) {
                        
            InformationDetailView(title: "Easily track your routes", imageName: "magnifyingglass")

            InformationDetailView(title: "Log your finds", imageName: "mappin")
            
            InformationDetailView(title: "View past routes and finds", imageName: "map")
            
        }
        .padding(.horizontal)
    }
}

struct InformationContainerView_Previews: PreviewProvider {
    static var previews: some View {
        InformationContainerView()
    }
}
