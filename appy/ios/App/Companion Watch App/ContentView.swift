import SwiftUI

struct ContentView: View {
  var body: some View {
    VStack {
      Text("🍽️")
        .font(.title)
      Spacer()
      // Calling the `eatFruit` function and `Fruits` enum
      // exposed from Rust.
      Text("Ready? \(eatFruit(fruit: Fruits.watermelon))")
        .font(.headline)
      Spacer()
    }
    .padding()
  }
}

#Preview {
  ContentView()
}
