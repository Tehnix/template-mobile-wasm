import SwiftUI

struct ContentView: View {
  var body: some View {
    VStack {
      Image(systemName: "globe")
        .imageScale(.large)
        .foregroundStyle(.tint)
      Text("Hello, world!")
      // Calling the `eatFruit` function and `Fruits` enum
      // exposed from Rust.
      Text("Ready? \(eatFruit(fruit: Fruits.watermelon))")
        .font(.headline)
    }
    .padding()
  }
}

#Preview {
  ContentView()
}
