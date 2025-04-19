import SwiftUI

struct PrimaryButtonTextModifier: ViewModifier {
    let foregroundColor: Color
    let backgroundColor: Color
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(
                    cornerRadius: 10,
                    style: .continuous
                )
                .fill(.blue)
            )
            .foregroundStyle(foregroundColor)
    }
}
