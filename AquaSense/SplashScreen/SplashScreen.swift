//
//  SplashScreen.swift
//  LuckyFinds
//
//  Created by Matthew Johnson on 12/24/21.
//

import Foundation
import SwiftUI
import Firebase

struct SplashScreen: View {
    @AppStorage("presentSplashScreen") var presentSplashScreen: Bool = true
    @AppStorage("loggedIn") var loggedIn: Bool = false
    @State var clickedButton = false

    var body: some View {
        ScrollView {
            VStack(alignment: .center) {

                Spacer(minLength: 50)

                TitleView()
                InformationContainerView()
            }
            .onAppear {
                Analytics.logEvent(AnalyticsEventTutorialBegin, parameters: [:])
            }
        }
        
        Button(action: {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            Analytics.logEvent(AnalyticsEventTutorialComplete, parameters: [:])
            
            if Auth.auth().currentUser == nil {
                if !clickedButton {
                    clickedButton = true
                    
                    presentSplashScreen = false
                    
                    //UserManager.shared.createNewAnnonymousUser() {_ in
                    //    loggedIn = true
                    //    presentSplashScreen = false
                    //}
                }
            } else {
                presentSplashScreen = false
                loggedIn = true
            }
        }) {
            Text("Continue")
                .bold()
                .foregroundColor(.white)
                .font(.headline)
                .padding()
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(Color.mainColor))
                .padding(.bottom)
                .padding(.horizontal)
                .padding(.horizontal)
                .frame(maxWidth: 450)
        }
        .disabled(clickedButton)
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
    }
}
