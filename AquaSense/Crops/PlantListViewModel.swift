import Foundation
import SwiftUI

class PlantListViewModel: ObservableObject {
    @Published var plants: [Plant] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    private let apiManager = PerenualAPIManager()
    
    func fetchPlants(page: Int = 1, edible: Bool = true, indoor: Bool = false, hardiness: Int? = nil, watering: Watering? = nil) {
        isLoading = true
        errorMessage = nil
        
        apiManager.fetchPlantData(
            page: page,
            edible: edible,
            indoor: indoor,
            hardiness: hardiness,
            watering: watering
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let plants):
                    self?.plants = plants
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
