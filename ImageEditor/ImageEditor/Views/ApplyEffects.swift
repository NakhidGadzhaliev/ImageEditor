import SwiftUI
import PhotosUI

struct ApplyEffects: View {
    private enum Constants {
        static let photo = "photo"
        static let wandAndRays = "wand.and.rays"
        static let squareUp = "square.and.arrow.up"
        static let squareDown = "square.and.arrow.down"
        static let filterKey = kCIInputIntensityKey
        static let photoBadgePlus = "photo.badge.plus"
        static let sliderLabelWidth: CGFloat = 80
        static let sliderPadding: CGFloat = 16
    }

    @StateObject var model = DrawingViewModel()
    @StateObject var signingViewModel: SignInViewModel
    
    @State private var processedImage: Image?
    @State private var selectedItem: PhotosPickerItem?
    
    @State private var rotationAngle: Double = 0
    @State private var scale: CGFloat = 1
    @State private var filterIntensity = 0.5
    
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    private let context = CIContext()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()
                imagePickerSection
                slidersSection
                controlButtons
            }
            .padding()
            
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: shareImage) {
                    Image(systemName: Constants.squareUp)
                }
                Button(action: saveImage) {
                    Image(systemName: Constants.squareDown)
                }
            }
        }
    }
    
    private var imagePickerSection: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {
            Group {
                if let image = processedImage {
                    image
                        .resizable()
                        .scaledToFit()
                        .rotationEffect(.degrees(rotationAngle))
                        .scaleEffect(scale)
                        .frame(maxHeight: 300)
                } else {
                    placeholderView
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .buttonStyle(.plain)
        .onChange(of: selectedItem) { _ in loadImage() }
    }
    
    @ViewBuilder
    private var placeholderView: some View {
        if #available(iOS 17.0, *) {
            ContentUnavailableView(MainConstants.noPicture,
                                   systemImage: Constants.photoBadgePlus,
                                   description: Text(MainConstants.tapToSelect))
        } else {
            Label(MainConstants.selectPicture, systemImage: Constants.photo)
        }
    }
    
    private var slidersSection: some View {
        VStack(spacing: 12) {
            sliderRow(label: MainConstants.intensity, value: $filterIntensity, range: 0...1) {
                applyFilter()
            }
            sliderRow(label: MainConstants.rotation, value: $rotationAngle, range: 0...360)
            sliderRow(label: MainConstants.zoom, value: $scale, range: 0.5...2)
        }
    }
    
    private func sliderRow(label: String, value: Binding<Double>, range: ClosedRange<Double>, onChange: (() -> Void)? = nil) -> some View {
        HStack {
            Text(label)
                .frame(width: Constants.sliderLabelWidth, alignment: .leading)
            Slider(value: value, in: range)
                .onChange(of: value.wrappedValue) { _ in onChange?() }
        }
        .padding(.horizontal, Constants.sliderPadding)
    }
    
    private func sliderRow(label: String, value: Binding<CGFloat>, range: ClosedRange<CGFloat>) -> some View {
        HStack {
            Text(label)
                .frame(width: Constants.sliderLabelWidth, alignment: .leading)
            Slider(value: value, in: range)
        }
        .padding(.horizontal, Constants.sliderPadding)
    }
    
    private var controlButtons: some View {
        HStack {
            Menu {
                Button(MainConstants.sepiaTone) {
                    currentFilter = .sepiaTone()
                    applyFilter()
                }
                Button(MainConstants.removeEffect) {
                    filterIntensity = 0
                    applyFilter()
                }
            } label: {
                Label(MainConstants.changeFilter, systemImage: Constants.wandAndRays)
            }

            Spacer()

            Button(MainConstants.removeImage) {
                processedImage = nil
            }
            .foregroundStyle(.red)
        }
        .padding(.horizontal, Constants.sliderPadding)
    }
    
    private func loadImage() {
        Task {
            do {
                if let image: Image = try await selectedItem?.loadTransferable(type: Image.self) {
                    self.processedImage = image
                }
                
                guard let data = try await selectedItem?.loadTransferable(type: Data.self),
                      let uiImage = UIImage(data: data) else { return }
                
                let ciImage = CIImage(image: uiImage)
                currentFilter.setValue(ciImage, forKey: kCIInputImageKey)
                applyFilter()
            } catch {
                print("\(MainConstants.errorLoadingImage) \(error)")
            }
        }
    }
    
    private func applyFilter() {
        currentFilter.setValue(filterIntensity, forKey: Constants.filterKey)
        
        guard let output = currentFilter.outputImage,
              let cgImage = context.createCGImage(output, from: output.extent) else { return }
        
        processedImage = Image(uiImage: UIImage(cgImage: cgImage))
    }

    private func shareImage() {
        guard let data = processedImage?.asUIImage().pngData() else { return }
        let controller = UIActivityViewController(activityItems: [data], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(controller, animated: true)
    }

    private func saveImage() {
        guard let data = processedImage?.asUIImage().pngData(),
              let uiImage = UIImage(data: data) else { return }
        UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
    }
}
