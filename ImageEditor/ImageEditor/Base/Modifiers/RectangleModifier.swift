import SwiftUI

struct RectangleModifier: ViewModifier {
    func body(content: Content) -> some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke()
            .foregroundColor(Color.gray10)
            .frame(height: 50)
    }
}
