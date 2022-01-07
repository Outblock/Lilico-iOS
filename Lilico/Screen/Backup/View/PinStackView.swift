//
//  TestView.swift
//  Lilico
//
//  Created by Hao Fu on 6/1/22.
//

import Introspect
import SwiftUI
import SwiftUIX

struct PinStackView: View {
    var maxDigits: Int
    var emptyColor: Color
    var highlightColor: Color

    @State
    var needClear: Bool = false {
        didSet {
            if needClear {
                pin = ""
            }
        }
    }

    @State
    var pin = ""

    // String is the pin code, bool is completed or not
    var handler: (String, Bool) -> Void

    func getPinColor(_ index: Int) -> Color {
        let pin = Array(self.pin)

        if pin.indices.contains(index), !String(pin[index]).isEmpty {
            return highlightColor
        }

        return emptyColor
    }

    var body: some View {
        ZStack {
            TextField("", text: $pin)
                .onReceive(pin.publisher.collect()) {
                    self.pin = String($0.prefix(maxDigits))
                    self.handler(self.pin, $0.count == maxDigits)
                }
                .introspectTextField { textField in
                    textField.becomeFirstResponder()
                    textField.isHidden = true
                }
                .keyboardType(.numberPad)

            HStack(spacing: 24) {
                ForEach(0 ..< maxDigits) { digit in
//                    Text(self.getPinNumber(digit)).padding().background(Color(.systemFill))
                    Circle()
                        .frame(width: 20, height: 20, alignment: .center)
                        .foregroundColor(self.getPinColor(digit))
                }
            }
        }
    }

    private func closeKeyboard() {
//        UIApplication.shared.endEditing() // Closing keyboard does not exist for swiftui yet
    }
}

struct PinStackView_Previews: PreviewProvider {
    static var previews: some View {
        PinStackView(maxDigits: 6,
                     emptyColor: .gray,
                     highlightColor: Color.LL.orange,
                     needClear: false) { pin, _ in
            print(pin)
        }
    }
}
