//
//  FilterView.swift
//  Paws-up
//
//  Created by Hanning Xu on 8/7/22.
//

import SwiftUI

struct FilterBar: View {
    @Binding var labels: [String]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(0..<3) {
                    FilterCell(label: "Item \($0)")
                        .frame(width: 70, height: 50)
                }
            }
        }
    }
}

struct FilterCell: View {
    @State var isSelected = false
    var label: String
    
    var body: some View {
        Button(action: {isSelected.toggle()}, label: {
            if isSelected {
                Text(label).foregroundColor(.white)
                    .background(RoundedRectangle(cornerRadius: 4).foregroundColor(Color("logo-pink"))
                        )
            } else {
                Text(label).foregroundColor(.black)
                    .background(RoundedRectangle(cornerRadius: 4).stroke().foregroundColor(.gray))
            }
        })
    }
}

//struct FilterCell: Identifiable {
//    var label: String
//    var isSelected: Bool
//
//    var id: Int
//}
//
struct FilterBar_Previews: PreviewProvider {
    var selected: Bool = false

    static var previews: some View {
        FilterBar()
    }
}
