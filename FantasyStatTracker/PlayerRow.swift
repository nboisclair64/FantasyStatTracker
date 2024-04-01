import SwiftUI

struct PlayerRow: View {
    var player: Player

    var body: some View {
        HStack(alignment: .top) {
            
            RemoteImageView(imageUrl: URL(string: player.headshot)!, placeholderImage: Image("mcdavid"))
                .frame(width: 60, height: 60).border(Color.black,width: 1)
            Spacer()
            VStack(alignment: .leading) {
                Text("Name").bold().multilineTextAlignment(.leading)
                Text(player.name)
            }.frame(maxWidth:100, maxHeight: 50)
            Spacer()
            VStack {
                Text("Goals").bold()
                Text("\(player.goals)") // Assuming player.goals is an Int property
            }
            VStack {
                Text("Assists").bold()
                Text("\(player.assists)") // Assuming player.assists is an Int property
            }
            VStack {
                Text("SOG").bold()
                Text("\(player.shots)") // Assuming player.sog is an Int property
            }
        }.frame(maxWidth:.infinity)
    }
}

struct RemoteImageView: View {
    let imageUrl: URL
    let placeholderImage: Image
    @State private var image: Image?

    var body: some View {
        if let image = image {
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            placeholderImage
                .resizable()
                .aspectRatio(contentMode: .fit)
                .onAppear {
                    loadImage(from: imageUrl)
                }
        }
    }

    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let uiImage = UIImage(data: data) {
                self.image = Image(uiImage: uiImage)
            }
        }.resume()
    }
}
