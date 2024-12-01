//
//  TitleView.swift
//  LuckyFinds
//
//  Created by Matthew Johnson on 12/24/21.
//

import SwiftUI

struct TitleView: View {
    var body: some View {
        VStack {
            Text("Welcome to")
                .customTitleText()
            
             // Uncomment this code if you want to add a logo to your welcome page.
             // Add a logo in your Assets.xcassets file and rename the below image
             // name to match the logo name.
             
             Image("Logo")
                 .resizable()
                 .aspectRatio(contentMode: .fit)
                 .frame(width: 125, alignment: .center)
                 .clipShape(RoundedRectangle(cornerRadius: 20))
                 .accessibility(hidden: true)

            Text(appName)
                .customTitleText()
                .foregroundColor(.mainColor)
        }
    }
}

struct TitleView_Previews: PreviewProvider {
    static var previews: some View {
        TitleView()
    }
}

// An extenstion allowing for a custom title text
extension Text {
    func customTitleText() -> Text {
        self
            .fontWeight(.black)
            .font(.system(size: 36))
    }
}
