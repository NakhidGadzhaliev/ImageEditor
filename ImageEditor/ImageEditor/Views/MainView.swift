import CoreImage
import CoreImage.CIFilterBuiltins
import PhotosUI
import SwiftUI
import PencilKit

struct MainView: View {
    private enum Constants {
        static let xmark = "xmark"
        static let squareUp = "square.and.arrow.up"
        static let squareDown = "square.and.arrow.down"
        static let plus = "plus"
        static let filterKey = "inputIntensity"
        static let normal = "Normal"
        static let bold = "Bold"
    }
    
    @StateObject var model = DrawingViewModel()
    @StateObject var signingViewModel: SignInViewModel
    @State private var processedImage: Image?
    @State private var selectedItem: PhotosPickerItem?
    @State private var rotationAngle: Double = 0.0
    @State private var scale: CGFloat = 1.0
    @State private var filterIntensity = 0.5
    @State private var canvasView = PKCanvasView()
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    
    let context = CIContext()
    
    var body: some View {
        ZStack {
            NavigationView {
                
                VStack {
                    
                    if let _ = UIImage(data: model.imageData) {
                        DrawingView()
                            .environmentObject(model)
                        
                        //                            .toolbar(content: {
                        //
                        //                                ToolbarItem(placement: .navigationBarLeading) {
                        //                                    Button(action: model.cancelImageEditing, label: {
                        //                                        Image(systemName: Constants.xmark)
                        //                                    })
                        //                                }
                        //                            })
                        
                    } else {
                        
                        Spacer()
                        
                        Button(action: {
                            model.showImagePicker.toggle()
                        }, label: {
                            Image(systemName: Constants.plus)
                                .font(.title)
                                .foregroundColor(.black)
                                .frame(width: 70, height: 70)
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(
                                    color: Color.black.opacity(0.07),
                                    radius: 5, x: 5, y: 5
                                )
                                .shadow(
                                    color: Color.black.opacity(0.07),
                                    radius: 5, x: -5, y: -5
                                )
                        })
                        
                        Spacer()
                    }
                }
            }
            .toolbar {
                if UIImage(data: model.imageData) != nil {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: model.shareImage, label: {
                            Image(systemName: Constants.squareUp)
                        })
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: model.saveImage, label: {
                            Image(systemName: Constants.squareDown)
                        })
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            withAnimation {
                                model.textSpaces.append(TextSpace())
                            }
                            model.currentIndex = model.textSpaces.count - 1
                            model.addNewSpace.toggle()
                            
                            model.toolPicker.setVisible(false, forFirstResponder: model.canvas)
                            model.canvas.resignFirstResponder()
                        }, label: {
                            Image(systemName: Constants.plus)
                        })
                    }
                }
            }
            
            
            if model.addNewSpace {
                Color.black.opacity(0.75)
                    .ignoresSafeArea()
                
                TextField(MainConstants.typeHere, text: $model.textSpaces[model.currentIndex].text)
                    .font(
                        .system(
                            size: 35,
                            weight: model.textSpaces[model.currentIndex].isBold
                            ? .bold
                            : .regular
                        )
                    )
                
                    .colorScheme(.dark)
                    .foregroundColor(model.textSpaces[model.currentIndex].textColor)
                    .padding()
                
                HStack {
                    Button(action: {
                        model.textSpaces[model.currentIndex].isAdded = true
                        model.toolPicker.setVisible(true, forFirstResponder: model.canvas)
                        model.canvas.becomeFirstResponder()
                        withAnimation {
                            model.addNewSpace = false
                        }
                        
                    }, label: {
                        Text(MainConstants.add)
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                            .padding()
                    })
                    
                    Spacer()
                    
                    Button(action: model.cancelTextView, label: {
                        Text(MainConstants.cancel)
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                            .padding()
                    })
                }
                .overlay(
                    HStack(spacing: 15) {
                        ColorPicker("", selection: $model.textSpaces[model.currentIndex].textColor).labelsHidden()
                        
                        Button(action: {
                            model.textSpaces[model.currentIndex].isBold.toggle()
                        }, label: {
                            Text(model.textSpaces[model.currentIndex].isBold ? Constants.normal : Constants.bold)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        })
                    }
                )
                .frame(maxHeight: .infinity, alignment: .top)
            }
        }
        .sheet(isPresented: $model.showImagePicker, content: {
            ImagePicker(showPicker: $model.showImagePicker, imageData: $model.imageData)
        })
        .alert(isPresented: $model.showAlert, content: {
            Alert(title: Text(MainConstants.message), message: Text(model.message), dismissButton: .default(Text(MainConstants.okString)))
        })
    }
    
    private func loadImage() {
        Task {
            do {
                processedImage = try await selectedItem?.loadTransferable(type: Image.self)
            } catch {
                print("\(MainConstants.errorLoadingImage.localizedCapitalized)  \(error)")
            }
            
            guard let imageData = try await selectedItem?.loadTransferable(type: Data.self) else {
                return
            }
            
            guard let inputImage = UIImage(data: imageData) else {
                return
            }
            
            let beginImage = CIImage(image: inputImage)
            currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
            applyFilter()
        }
    }
    
    private func applyFilterOnce() {
        currentFilter.setValue(filterIntensity, forKey: Constants.filterKey)
        
        guard let outputImage = currentFilter.outputImage else { return }
        
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return }
        
        let uiImage = UIImage(cgImage: cgImage)
        let image = Image(uiImage: uiImage)
        processedImage = image
    }
    
    
    private func applyFilter(filter: CIFilter) {
        if filter.attributes.keys.contains(kCIInputIntensityKey) {
            filter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
        }
        
        guard let outputImage = filter.outputImage else { return }
        
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return }
        
        let uiImage = UIImage(cgImage: cgImage)
        let image = Image(uiImage: uiImage)
        processedImage = image
    }
    
    private func applyFilter() {
        currentFilter.setValue(filterIntensity, forKey: Constants.filterKey)
        
        guard let outputImage = currentFilter.outputImage else { return }
        
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return }
        
        let uiImage = UIImage(cgImage: cgImage)
        let image = Image(uiImage: uiImage)
        processedImage = image
    }
}
