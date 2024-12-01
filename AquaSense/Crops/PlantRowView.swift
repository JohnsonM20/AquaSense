struct PlantRowView: View {
    let plant: Plant
    
    var body: some View {
        HStack {
            if let imageUrl = plant.defaultImage?.thumbnail, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            VStack(alignment: .leading) {
                Text(plant.commonName ?? "Unknown Name")
                    .font(.headline)
                Text(plant.scientificName.joined(separator: ", "))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Watering: \(plant.watering)")
                    .font(.caption)
            }
        }
    }
}