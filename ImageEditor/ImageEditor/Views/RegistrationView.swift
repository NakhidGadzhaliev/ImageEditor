import SwiftUI

struct RegistrationView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var model = DrawingViewModel()
    @StateObject var signingViewModel: SignInViewModel
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isValidEmail = false
    @State private var isValidPassword = false
    @State private var isMainViewPresented = false
    @State private var showAlert = false
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack {
                    Spacer(minLength: 50)
                    
                    Text("Регистрация")
                        .font(.largeTitle)
                        .bold()
                        .padding(.bottom, 20)
                    
                    VStack(spacing: 16) {
                        CustomInputField(icon: "envelope", placeholder: MainConstants.emailString, text: $email, isSecure: false)
                            .onChange(of: email) { _ in
                                isValidEmail = true
                            }

                        CustomInputField(icon: "lock", placeholder: MainConstants.passwordString, text: $password, isSecure: true)
                            .onChange(of: password) { _ in
                                isValidPassword = true
                            }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                    .padding(.horizontal)

                    Button(action: {
                        validateAndRegister()
                    }) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                        } else {
                            Text(MainConstants.register)
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text(MainConstants.invalidData),
                            message: Text(MainConstants.invalidPasswordOrEmail),
                            dismissButton: .default(Text(MainConstants.okString))
                        )
                    }
                    
                    DividerByOrView()
                        .padding(.top)

                    GoogleSigningButton(isSignIn: true) {
                        signingViewModel.signInWithGoogle(completion: { success in })
                    }
                    .padding(.top, 5)
                    
                    Spacer()
                    
                    HStack {
                        Text(MainConstants.alreadyhaveAccount)
                            .foregroundColor(.gray)
                        Button(MainConstants.authString) {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .bold()
                    }
                    .padding(.bottom, 30)
                }
                .onAppear {
                    signingViewModel.signInSuccessCallback = {
                        isMainViewPresented = true
                    }
                }
                .fullScreenCover(isPresented: $isMainViewPresented) {
                    OptionView()
                }
                .navigationTitle("")
                .navigationBarHidden(true)
            }
        }
    }
    
    private func validateAndRegister() {
        isValidEmail = Validator.isValidEmail(email)
        isValidPassword = Validator.isValidPassword(password)
        
        guard isValidEmail, isValidPassword else {
            showAlert = true
            return
        }

        isLoading = true
        signingViewModel.signIn(email: email, password: password) { success in
            isLoading = false
            if !success {
                showAlert = true
            }
        }
    }
}
