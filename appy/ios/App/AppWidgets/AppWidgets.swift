import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
  func placeholder(in _: Context) -> SimpleEntry {
    SimpleEntry(date: Date(), emoji: "😀")
  }

  func getSnapshot(in _: Context, completion: @escaping (SimpleEntry) -> Void) {
    let entry = SimpleEntry(date: Date(), emoji: "😀")
    completion(entry)
  }

  func getTimeline(in _: Context, completion: @escaping (Timeline<Entry>) -> Void) {
    var entries: [SimpleEntry] = []

    // Generate a timeline consisting of five entries an hour apart, starting from the current date.
    let currentDate = Date()
    for hourOffset in 0 ..< 5 {
      let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
      let entry = SimpleEntry(date: entryDate, emoji: "😀")
      entries.append(entry)
    }

    let timeline = Timeline(entries: entries, policy: .atEnd)
    completion(timeline)
  }
}

struct SimpleEntry: TimelineEntry {
  let date: Date
  let emoji: String
}

struct AppWidgetsEntryView: View {
  var entry: Provider.Entry

  var body: some View {
    VStack {
      Text("Ready? \(eatFruit(fruit: Fruits.watermelon))")
        .font(.headline)
      
      Spacer()
      
      HStack {
        Text("Time:")
        Text(self.entry.date, style: .time)
      }

      HStack {
        Text("Emoji:")
        Text(self.entry.emoji)
      }
      Spacer()
    }
  }
}

struct AppWidgets: Widget {
  let kind: String = "AppWidgets"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: self.kind, provider: Provider()) { entry in
      if #available(iOS 17.0, *) {
        AppWidgetsEntryView(entry: entry)
          .containerBackground(.fill.tertiary, for: .widget)
      } else {
        AppWidgetsEntryView(entry: entry)
          .padding()
          .background()
      }
    }
    .configurationDisplayName("My Widget")
    .description("This is an example widget.")
  }
}

#Preview(as: .systemMedium) {
  AppWidgets()
} timeline: {
  SimpleEntry(date: .now, emoji: "😀")
  SimpleEntry(date: .now, emoji: "🤩")
}
