//
//  LilicoWidgets.swift
//  LilicoWidgets
//
//  Created by Selina on 20/12/2022.
//

import WidgetKit
import SwiftUI
import Kingfisher

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct LilicoWidgetsEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        Image("AppIcon")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
//        KFImage.url(nil)
//            .placeholder({
//                Image("placeholder")
//                    .resizable()
//            })
//            .resizable()
//            .aspectRatio(contentMode: .fill)
//            .frame(width: 16, height: 16)
//            .cornerRadius(8)
    }
}

struct LilicoWidgets: Widget {
    let kind: String = "LilicoWidgets"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            LilicoWidgetsEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct LilicoWidgets_Previews: PreviewProvider {
    static var previews: some View {
        LilicoWidgetsEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
