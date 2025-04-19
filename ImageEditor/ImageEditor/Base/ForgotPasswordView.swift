import SwiftUI
import Firebase

struct ForgotPasswordView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var email: String = .empty
    @State private var isPasswordRecoveryLinkSent: Bool = false
    
    @State private var showAlert = false
    @State private var errorDescription: String = .empty
    
    var body: some View {
        VStack {
            Text(MainConstants.forgotPassword)
                .font(.title)
            
            ZStack(alignment: .leading) {
                Rectangle()
                    .withTextFieldRectangleModifier()
                TextField(MainConstants.enterEmail, text: $email)
                    .withDefaultTextFieldModifier()
            }
            
            Button(action: {
                let auth = Auth.auth()
                
                auth.sendPasswordReset(withEmail: email) { error in
                    if let error = error {
                        errorDescription = error.localizedDescription
                        self.showAlert = true
                    } else {
                        self.isPasswordRecoveryLinkSent = true
                    }
                }
            }) {
                Text(MainConstants.recoveryEmail)
            }
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(title: Text(MainConstants.error), message: Text(errorDescription), dismissButton: .default(Text(MainConstants.okString)))
            }
            
            Spacer()
        }
        .padding()
        .navigationBarTitle(MainConstants.passwordRecovery)
        .alert(isPresented: $isPasswordRecoveryLinkSent) {
            Alert(title: Text(MainConstants.passwordRecovery),
                  message: Text("\(MainConstants.passwordRecoveryLink) \(email)"),
                  dismissButton: .default(Text(MainConstants.okString)) {
                self.presentationMode.wrappedValue.dismiss()
            })
        }
        .background(VStack {})
    }
}
