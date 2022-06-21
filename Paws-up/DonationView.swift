//
//  DonationView.swift
//  Paws-up
//
//  Created by 那桐 on 6/20/22.
//

import Foundation
import SwiftUI

struct DonationView: View {
    var body: some View {
        Image(uiImage: UIImage(named: "venmo") ?? UIImage())
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 400)
    }
}
