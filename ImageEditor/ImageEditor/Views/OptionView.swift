import SwiftUI

struct OptionView: View {
    @StateObject var signingViewModel = SignInViewModel()
    @State private var isLoggedOut = false
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            HStack {
                NavigationLink(
                    MainConstants.applyEffect,
                    destination: ApplyEffects(
                        model: DrawingViewModel(),
                        signingViewModel: SignInViewModel()
                    )
                )
                .buttonStyle(.bordered)
            }
            
            HStack {
                NavigationLink(
                    MainConstants.drawString,
                    destination: MainView(
                        model: DrawingViewModel(),
                        signingViewModel: SignInViewModel()
                    )
                )
                .buttonStyle(.bordered)
            }
            
            Spacer()
            
            HStack {
                Text(MainConstants.signedIn)
                    .foregroundStyle(.black)
                
                Button {
                    signingViewModel.signOut()
                    isLoggedOut = true
                } label: {
                    Text(MainConstants.signOut)
                        .foregroundStyle(.blue)
                }
            }
        }
        .fullScreenCover(isPresented: $isLoggedOut) {
            NavigationView {
                LoginView()
            }
        }
    }
}
