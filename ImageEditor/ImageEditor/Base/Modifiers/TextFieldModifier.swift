import SwiftUI

struct TextFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            .frame(height: 50)
            .foregroundStyle(.black)
            .padding(.leading, 10)
    }
}
