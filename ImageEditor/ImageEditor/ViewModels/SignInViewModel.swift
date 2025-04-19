import GoogleSignIn
import Firebase

final class SignInViewModel: ObservableObject {
    var signInSuccessCallback: (() -> Void)?
    
    let auth = Auth.auth()
    
    @Published var signedIn = false
    
    var isSignedIn: Bool { return auth.currentUser != nil }
    
    func signIn(email: String, password: String, completion: @escaping (Bool) -> Void) {
        auth.signIn(withEmail: email, password: password) { [weak self] result, error in
            
            if let error = error {
                print(MainConstants.errorSigningIn, error.localizedDescription)
                completion(false)
                return
            }
            
            if let user = self?.auth.currentUser {
                if !user.isEmailVerified {
                    user.sendEmailVerification { (error) in
                        if let error = error {
                            print(error.localizedDescription)
                            completion(false)
                        }
                    }
                }
            }
            
            DispatchQueue.main.async {
                self?.signedIn = true
                completion(true)
            }
        }
    }
    
    func signUp(email: String, password: String, completion: @escaping (Bool) -> Void) {
        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            
            if let error = error {
                print(MainConstants.errorSigningIn, error.localizedDescription)
                completion(false)
                return
            }
            
            if let user = self?.auth.currentUser {
                if !user.isEmailVerified {
                    user.sendEmailVerification { (error) in
                        if let error = error {
                            print(error.localizedDescription)
                            completion(false)
                        }
                    }
                }
            }
            
            DispatchQueue.main.async {
                self?.signedIn = true
                completion(true)
            }
        }
    }
    
    func signOut() {
        try? auth.signOut()
        self.signedIn = false
    }
    
    func signInWithGoogle(completion: @escaping (Bool) -> Void) {
        
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(
            withPresenting: ApplicationUtils.rootViewController) { user, error in
                
                if let error = error {
                    print(error.localizedDescription)
                    completion(false)
                    return
                }
                
                guard
                    let user = user?.user,
                    let idToken = user.idToken
                else { return }
                
                let accessToken = user.accessToken
                let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString,
                                                               accessToken: accessToken.tokenString)
                
                Auth.auth().signIn(with: credential) { result, error in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    
                    guard let user = result?.user else { return }
                    print(user)
                    
                    self.signInSuccessCallback?()
                }
                
                DispatchQueue.main.async {
                    self.signedIn = true
                    completion(true)
                }
            }
    }
}
