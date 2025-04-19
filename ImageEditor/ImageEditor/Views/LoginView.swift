import SwiftUI
import GoogleSignIn

struct LoginView: View {
    @StateObject var signingViewModel = SignInViewModel()
    @EnvironmentObject var model: DrawingViewModel
    @State private var isRecoveryViewPresented = false
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isValidEmail = true
    @State private var isValidPassword = false
    @State private var isMainViewPresented = false
    @FocusState private var isPasswordFieldFocused: Bool
    
    @State private var showAlert = false
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack {
                    Spacer(minLength: 50)
                    
                    Text("Добро пожаловать")
                        .font(.largeTitle)
                        .bold()
                        .padding(.bottom, 20)
                    
                    VStack(spacing: 16) {
                        CustomInputField(icon: "envelope", placeholder: MainConstants.emailString, text: $email, isSecure: false)
                            .onChange(of: email) { _ in
                                isValidEmail = true
                            }

                        CustomInputField(icon: "lock", placeholder: MainConstants.passwordString, text: $password, isSecure: true)
                            .focused($isPasswordFieldFocused)
                            .onChange(of: password) { _ in
                                isValidPassword = true
                            }
                        
                        HStack {
                            Spacer()
                            Button(MainConstants.forgotPassword) {
                                isRecoveryViewPresented.toggle()
                            }
                            .font(.footnote)
                            .foregroundColor(.blue)
                            .sheet(isPresented: $isRecoveryViewPresented) {
                                ForgotPasswordView()
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                    .padding(.horizontal)

                    Button(action: {
                        validateAndSignIn()
                    }) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                        } else {
                            Text(MainConstants.signIn)
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
                        Alert(title: Text(MainConstants.invalidData), message: Text(MainConstants.invalidPasswordOrEmail), dismissButton: .default(Text(MainConstants.okString)))
                    }
                    
                    DividerByOrView()
                        .padding(.top)
                    
                    GoogleSigningButton(isSignIn: true) {
                        signingViewModel.signInWithGoogle(completion: { success in })
                    }
                    .padding(.top, 5)
                    
                    Spacer()
                    
                    HStack {
                        Text(MainConstants.dontHaveAccount)
                            .foregroundColor(.gray)
                        NavigationLink(destination: RegistrationView(signingViewModel: signingViewModel)) {
                            Text(MainConstants.register)
                                .bold()
                        }
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
    
    private func validateAndSignIn() {
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

struct CustomInputField: View {
    var icon: String
    var placeholder: String
    @Binding var text: String
    var isSecure: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
            if isSecure {
                SecureField(placeholder, text: $text)
                    .autocapitalization(.none)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
