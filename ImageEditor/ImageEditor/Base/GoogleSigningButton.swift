import SwiftUI

struct GoogleSigningButton: View {
    
    let isSignIn: Bool
    let onTapAction: () -> Void
    
    var body: some View {
        Button(action: onTapAction) {
            HStack {
                Image(.googleLogo)
                    .resizable()
                    .frame(width: 24, height: 24)
                
                Text(MainConstants.signWithGoogle)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
            }
            .foregroundColor(.clear)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .background(
            RoundedRectangle(cornerRadius: 10,
                             style: .continuous)
            .fill(Color.gray10)
        )
    }
}
