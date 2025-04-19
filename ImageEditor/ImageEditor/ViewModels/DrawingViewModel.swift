import SwiftUI
import PencilKit

final class DrawingViewModel: ObservableObject {
    @Published var showImagePicker = false
    @Published var imageData: Data = Data(count: 0)
    @Published var canvas = PKCanvasView()
    @Published var toolPicker = PKToolPicker()
    @Published var textSpaces : [TextSpace] = []
    @Published var addNewSpace = false
    @Published var currentIndex: Int = 0
    @Published var rect: CGRect = .zero
    @Published var showAlert = false
    @Published var message: String = .empty
    
    @Environment(\.undoManager) private var undoManager
    
    var generatedImage: UIImage?
    
    func undo() {
        undoManager?.undo()
    }
    
    func cancelImageEditing() {
        imageData = Data(count: 0)
        textSpaces.removeAll()
    }
    
    func cancelTextView() {
        
        toolPicker.setVisible(true, forFirstResponder: canvas)
        canvas.becomeFirstResponder()
        
        withAnimation {
            addNewSpace = false
        }
        
        if !textSpaces[currentIndex].isAdded {
            textSpaces.removeLast()
        }
    }
    
    func saveImage() {
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        
        canvas.drawHierarchy(in: CGRect(origin: .zero, size: rect.size), afterScreenUpdates: true)
        
        let SwiftUIView = ZStack {
            ForEach(textSpaces) { [self] box in
                Text(textSpaces[currentIndex].id == box.id && addNewSpace ? .empty : box.text)
                    .font(.system(size: 30))
                    .fontWeight(box.isBold ? .bold : .none)
                    .foregroundColor(box.textColor)
                    .offset(box.offset)
            }
        }
        
        let controller = UIHostingController(rootView: SwiftUIView).view!
        
        controller.frame = rect
        controller.backgroundColor = .clear
        canvas.backgroundColor = .clear
        
        controller.drawHierarchy(in: CGRect(origin: .zero, size: rect.size), afterScreenUpdates: true)
        
        let generatedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        if let image = generatedImage?.pngData() {
            UIImageWriteToSavedPhotosAlbum(UIImage(data: image)!, nil, nil, nil)
            
            self.message = MainConstants.success
            self.showAlert.toggle()
        }
    }
    
    func shareImage() {
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        
        canvas.drawHierarchy(in: CGRect(origin: .zero, size: rect.size), afterScreenUpdates: true)
        
        
        let SwiftUIView = ZStack {
            ForEach(textSpaces) { [self] box in
                Text(
                    textSpaces[currentIndex].id == box.id && addNewSpace
                    ? .empty
                    : box.text
                )
                .font(.system(size: 30))
                .fontWeight(box.isBold ? .bold : .none)
                .foregroundColor(box.textColor)
                .offset(box.offset)
            }
        }
        
        let controller = UIHostingController(rootView: SwiftUIView).view!
        controller.frame = rect
        controller.backgroundColor = .clear
        canvas.backgroundColor = .clear
        
        controller.drawHierarchy(in: CGRect(origin: .zero, size: rect.size), afterScreenUpdates: true)
        
        let generatedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        self.generatedImage = generatedImage
        
        if let image = self.generatedImage {
            
            let activityViewController = UIActivityViewController(activityItems: [image.pngData() as Any], applicationActivities: nil)
            UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
        }
    }
}
