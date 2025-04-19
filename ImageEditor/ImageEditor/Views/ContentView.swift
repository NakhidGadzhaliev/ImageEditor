import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @EnvironmentObject var signingViewModel: SignInViewModel
    @StateObject var model = DrawingViewModel()
    
    var body: some View {
        
        NavigationView {
            if signingViewModel.signedIn {
                OptionView()
            } else {
                LoginView(signingViewModel: signingViewModel)
            }
        }
        .onAppear {
            signingViewModel.signedIn = signingViewModel.isSignedIn
        }
        .preferredColorScheme(.light)
    }
}
