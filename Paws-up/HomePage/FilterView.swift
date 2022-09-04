//
//  FilterView.swift
//  Paws-up
//
//  Created by Hanning Xu on 8/7/22.
//

import SwiftUI

struct FilterBar: View {
    // which labels are currently selected
    // @Binding var labels: [String]
    let labels: [String] = []
    @State var values: [Bool] = []
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(labels.indices, id: \.self) { index in
                    Button(action: {values[index].toggle()
                        // update homepage posts
                    }, label: {
                        if values[index] {
                            Text(labels[index]).foregroundColor(.white)
                                .background(RoundedRectangle(cornerRadius: 4).foregroundColor(Color("logo-pink")))
                        } else {
                            Text(labels[index]).foregroundColor(.black)
                                .background(RoundedRectangle(cornerRadius: 4).stroke().foregroundColor(.gray))
                        }
                    })
                }
            }
        }
    }
}
// combine the two views, make
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
    static var previews: some View {
        FilterBar()
    }
}
