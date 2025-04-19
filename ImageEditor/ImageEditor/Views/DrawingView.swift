import SwiftUI
import PencilKit

struct DrawingView: View {
    private enum Constants {
        static let squareUp = "square.and.arrow.up"
        static let squareDown = "square.and.arrow.down"
        static let plus = "plus"
    }
    
    @EnvironmentObject var model: DrawingViewModel
    
    var body: some View {
        ZStack {
            GeometryReader { proxy -> AnyView in
                let size = proxy.frame(in: .global)
                
                DispatchQueue.main.async {
                    if model.rect == .zero {
                        model.rect = size
                    }
                }
                
                return AnyView(
                    ZStack {
                        CanvasView(canvas: $model.canvas, imageData: $model.imageData, toolPicker: $model.toolPicker, rect: size.size)
                        
                        ForEach(model.textSpaces) { box in
                            Text(
                                model.textSpaces[model.currentIndex].id == box.id && model.addNewSpace
                                ? .empty
                                : box.text
                            )
                                .font(.system(size: 30))
                                .fontWeight(box.isBold ? .bold : .none)
                                .foregroundColor(box.textColor)
                                .offset(box.offset)
                                .gesture(DragGesture().onChanged({ (value) in
                                    
                                    let current = value.translation
                                    let lastOffset = box.lastOffset
                                    let newTranslation = CGSize(
                                        width: lastOffset.width + current.width,
                                        height: lastOffset.height + current.height
                                    )
                                    
                                    model.textSpaces[getIndex(textSpace: box)].offset = newTranslation
                                    
                                }).onEnded({ (value) in
                                    model.textSpaces[getIndex(textSpace: box)].lastOffset = value.translation
                                }))
                                .onLongPressGesture {
                                    model.toolPicker.setVisible(false, forFirstResponder: model.canvas)
                                    model.canvas.resignFirstResponder()
                                    model.currentIndex = getIndex(textSpace: box)
                                    withAnimation {
                                        model.addNewSpace = true
                                    }
                                }
                        }
                        
                    }
                )
            }
        }
//        .toolbar(content: {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button(action: model.shareImage, label: {
//                    Image(systemName: Constants.squareUp)
//                })
//            }
//            
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button(action: model.saveImage, label: {
//                    Image(systemName: Constants.squareDown)
//                })
//            }
//            
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button(action: {
//                    withAnimation {
//                        model.textSpaces.append(TextSpace())
//                    }
//                    model.currentIndex = model.textSpaces.count - 1
//                    model.addNewSpace.toggle()
//                    
//                    model.toolPicker.setVisible(false, forFirstResponder: model.canvas)
//                    model.canvas.resignFirstResponder()
//                }, label: {
//                    Image(systemName: Constants.plus)
//                })
//            }
//        })
    }
    
    func getIndex(textSpace: TextSpace) -> Int {
        let index = model.textSpaces.firstIndex { (box) -> Bool in
            return textSpace.id == box.id
        } ?? 0
        
        return index
    }
}
