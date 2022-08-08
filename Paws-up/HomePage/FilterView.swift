//
//  FilterView.swift
//  Paws-up
//
//  Created by Hanning Xu on 8/7/22.
//

//import SwiftUI
//
//struct FilterBar: View {
//    @State var items: [FilterCell]
//    
//    var body: some View {
//        HStack {
//            ForEach(items) { item in
//                Button(action: {item.isSelected.toggle()},
//                       label: {if item.isSelected {
//                           Text(item.label).foregroundColor(Color("logo-pink"))} else {
//                               Text(item.label).foregroundColor(Color("white"))
//                           }})
//            }
//        }
//    }
//}
//
//struct FilterCell: Identifiable {
//    var label: String
//    var isSelected: Bool;
//    
//    var id: Int
//}
//
//struct FilterBar_Previews: PreviewProvider {
//    var selected: Bool = false
//    
//    static var previews: some View {
//        FilterBar(items: [FilterCell(label: "Dog", isSelected: selected, id: 0),
//                          FilterCell(label: "Cat", isSelected: <#T##Binding<Bool>#>, id: 1)])
//    }
//}
