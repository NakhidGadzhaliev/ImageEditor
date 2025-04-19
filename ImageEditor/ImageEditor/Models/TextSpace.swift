import SwiftUI

struct TextSpace: Identifiable {
    var id = UUID().uuidString
    var text:  String = .empty
    var isBold: Bool = false
    var offset: CGSize = .zero
    var lastOffset: CGSize = .zero
    var textColor: Color = .white
    var isAdded: Bool = false
}
