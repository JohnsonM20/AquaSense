//
//  StartingView.swift
//  LuckyFinds
//
//  Created by Matthew Johnson on 4/10/21.
//

import SwiftUI

struct StartingView: View {
    @AppStorage("loggedIn") var loggedIn: Bool = false
    @AppStorage("presentSplashScreen") var presentSplashScreen: Bool = true
    @StateObject var dataModel = DataModel()

    var body: some View {
        if presentSplashScreen || presentSplashScreenForTesting {
            SplashScreen()
                .environmentObject(dataModel)
            
        } else if loggedIn {
            MainAppView()
                .environmentObject(dataModel)
                .fullScreenCover(isPresented: $dataModel.showSubscriptionSheet) {
                    SubscriptionView(showSpecialOffer: false)
                        .environmentObject(dataModel)
                }
            
        } else {
            SignedOutView()
                .environmentObject(dataModel)
        }
    }
}

struct StartingView_Previews: PreviewProvider {
    static var previews: some View {
        StartingView()
    }
}
