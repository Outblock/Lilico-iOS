//
//  LilicoWidgets.swift
//  LilicoWidgets
//
//  Created by Selina on 20/12/2022.
//

import WidgetKit
import SwiftUI
import Kingfisher

extension String {
    var localized: String {
        let value = NSLocalizedString(self, comment: "")
        if value != self || NSLocale.preferredLanguages.first == "en" {
            return value
        }
        
        guard let path = Bundle.main.path(forResource: "en", ofType: "lproj"), let bundle = Bundle(path: path) else {
            return value
        }
        
        return NSLocalizedString(self, bundle: bundle, comment: "")
    }

    func localized(_ args: CVarArg...) -> String {
        return String.localizedStringWithFormat(localized, args)
    }
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), image: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let urlString = ""
        let urlObj = URL(string: urlString)!
        KingfisherManager.shared.retrieveImage(with: urlObj) { result in
            switch result {
            case .success(let value):
                let entry = SimpleEntry(date: Date(), image: value.image)
                completion(entry)
            case .failure(let error):
                debugPrint("getSnapshot fetch image failed: \(error) ")
                let entry = SimpleEntry(date: Date(), image: nil)
                completion(entry)
            }
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, image: nil)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let image: UIImage?
}

struct LilicoWidgetsEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        if let image = entry.image {
            SmallView(image: image)
        } else {
            PlaceholderView()
        }
    }
}

struct PlaceholderView: View {
    var body: some View {
        Image("logo-new")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SmallView: View {
    let image: UIImage
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct LilicoWidgets: Widget {
    let kind: String = "LilicoWidgets"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            LilicoWidgetsEntryView(entry: entry)
        }
        .configurationDisplayName("widget_name".localized)
        .description("widget_desc".localized)
    }
}
