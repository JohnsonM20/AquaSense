//
//  DataModel.swift
//  LuckyFinds
//
//  Created by Matthew Johnson on 11/3/24.
//

import Foundation
import FirebaseFirestore
import SwiftUI
import FirebaseAuth

class DataModel: ObservableObject, @unchecked Sendable {
    @AppStorage("loggedIn") var loggedIn: Bool = false
    @AppStorage(UserDefaultsKeys.hasSubscription) var hasSubscription: Bool = false
    
    var profileListener: ListenerRegistration?
    
    /// To update the user's profile, update the @Published var profile, then call update
    @Published var profile: Profile = Profile()
    @Published var routes: [Route] = []
    @Published var finds: [Item] = []
    @Published var categories: [String] = []
    // var exampleCategories = ["Uncategorized", "Bottle Cap", "Button", "Coin", "Jewelry", "Pull Tab", "Ring", "Scrap Metal", "Toy"]
    @Published var didLoadDatabase = false
    @Published var displayRestoreRouteAlert = false
    @Published var currentRoute: Route = Route()
    var timer: Timer?
    
    @Published var showSubscriptionSheet = false
    
    init(){
        initializeRevenueCat()
        listenToUserLoginStatus()
    }
    
    func route(id: String) -> Route {
        return routes.first { $0.documentID == id } ?? Route()
    }
    
    func handleSubscriptionSheet(){
        let timesOpenedApp = defaults.integer(forKey: UserDefaultsKeys.timesOpenedApp)
        ///print("timesOpenedApp \(timesOpenedApp)")
        if !hasSubscription {
            if timesOpenedApp % 8 == 1 || timesOpenedApp % 8 == 2 {
                showSubscriptionSheet = true
            }
        }
    }
    
    /// called after login status determined
    func initData(){
        //print("initData")
        listenProfile()
        liveListenRoutes()
        self.rcLogIn()
    }
    
    private func listenProfile(){
        profileListener?.remove()
        guard let profileID = Auth.auth().currentUser?.uid else { return }
        
        profileListener = db.collection("users").document(profileID).addSnapshotListener { (documentSnapshot, error) in
            guard let snapshot = documentSnapshot, snapshot.exists else { return }
            guard let profile = try? snapshot.data(as: Profile.self) else { return }
            self.profile = profile
        }
    }
    
    private func liveListenRoutes(){
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userID).collection("routes")
            .addSnapshotListener { documentSnapshot, error in
                guard let documents = documentSnapshot?.documents else { return }

                let routes = documents.compactMap { (queryDocumentSnapshot) -> Route? in
                    return try? queryDocumentSnapshot.data(as: Route.self)
                }

                self.routes = routes.sorted { $0.startDate > $1.startDate }
                self.getSortedFinds()
                self.checkForUnfinishedRoute()

            }
    }
    
    private func getSortedFinds(){
        finds = []
        categories = []
        
        for route in routes {
            for item in route.items {
                //print("route id 1 \(route.documentID)")
                //print("route id 2 \(item.routeID)")
                //let newItem = item
                //print("route id 3 \(newItem.routeID)")
                //newItem.routeID = route.documentID
                categories.append(item.category)
                //finds.append(newItem)
                finds.append(item)
            }
        }
        
        finds.sort { $0.timeFound > $1.timeFound }
        categories = Array(Set(categories))
        categories.sort()
    }
    
    func returnUnfinishedRoute() -> Route? {
        for route in routes {
            if !route.completed {
                return route
            }
        }
        
        return nil
    }
    
    
    func performOnAppearActions(){
        // print("USER ID: \(Auth.auth().currentUser?.uid ?? "NO USER")")
        
//        if didSetUpRC == false {
//            UserManager.shared.setUpRevenueCat()
//            didSetUpRC = true
//        }
        
//        guard let userID = Auth.auth().currentUser?.uid else { return }
//        UserManager.shared.returnProfileFromDefaultsOrDatabase(profileID: userID) { profile in
//            self.profile = profile
//            //self.checkPremium()
//        }
        
        if !didLoadDatabase {
            self.didLoadDatabase = true
            //print("did not load database")
//            UserManager.shared.returnProfileFromDatabase(profileID: userID){ profile in
//                if profile != nil {
//                    self.profile = profile
//                    //self.checkPremium()
//                    self.didLoadDatabase = true
//
//                    if shouldAdvertiseProContentPopup {
//                        self.handleEmailSheet()
//                        self.handleSubscriptionSheet()
//                    }
//                }
//            }
            
            if shouldAdvertiseProContentPopup {
                //self.handleEmailSheet()
                //self.handleSubscriptionSheet()
            }
            
            UserManager.shared.registerForPushNotifications()
            UserManager.shared.setLastUserOpenDate()
            AppStoreReviewManager.requestReview()
            
        }
    }
    
//    private func checkPremium(){
//        guard let profile = profile else { return }
//        if profile.hasPremium() {
//            hasPremium = true
//        } else {
//            hasPremium = false
//        }
//    }
    
    private func checkForUnfinishedRoute() {
//        let routesViewModel = RoutesViewModel()
//        routesViewModel.getSortedRoutes()
        guard let unfinishedRoute = returnUnfinishedRoute() else { return }
        
        if currentRoute.documentID != unfinishedRoute.documentID {
            currentRoute = unfinishedRoute
            displayRestoreRouteAlert = true
        }

        //print("UNFINISHED ROUTE!!!!!!!!!!!!!")
    }
    
    func startRoute(){
        sendTapFeedback()
        currentRoute = Route()
    }
    
    func endRoute(){
        sendTapFeedback()
        currentRoute.completed = true
        currentRoute.endDate = Date()
        currentRoute.lastEdited = Date()
        
        if currentRoute.name == "" {
            currentRoute.name = currentRoute.returnDefaultRouteName()
        }
        
        currentRoute.save()
    }
    
    func pauseRoute(){
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)

    }
    
    @objc func updateTimer() {
        currentRoute.secondsPaused += 1
    }
    
    func unpauseRoute(){
        if let timer = self.timer {
            timer.invalidate()
            self.timer = nil
        }
    }
    
}
