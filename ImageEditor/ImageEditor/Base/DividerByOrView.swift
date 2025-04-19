import SwiftUI

struct DividerByOrView: View {
    var body: some View {
        HStack {
            Rectangle()
                .frame(height: 1)
                .padding(10)
                .foregroundStyle(Color.gray20)
            
            Text(MainConstants.orString)
            
            Rectangle()
                .frame(height: 1)
                .padding(10)
                .foregroundStyle(Color.gray20)
        }
    }
}
