//
//  InformationDetailView.swift
//  LuckyFinds
//
//  Created by Matthew Johnson on 12/24/21.
//

import SwiftUI

struct InformationDetailView: View {
    var title: String = "exampleTitle"
    var imageName: String = "exampleImage"

    var body: some View {
        HStack(alignment: .center) {
            
            Image(systemName: imageName)
                .font(.largeTitle)
                .foregroundColor(.mainColor)
                .padding()
                .accessibility(hidden: true)
                .frame(minWidth: 50, idealWidth: 50, maxWidth: 50)

            VStack(alignment: .leading) {
                Text(title.localized())
                    .font(.headline)
                    .foregroundColor(.primary)
                    .accessibility(addTraits: .isHeader)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.top)
    }
}

struct InformationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        InformationDetailView()
    }
}
