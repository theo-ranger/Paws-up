//
//  MapView.swift
//  Paws-up
//
//  Created by 那桐 on 6/20/22.
//

import Foundation
import SwiftUI
import MapKit

import Foundation
import SwiftUI
import MapKit

struct MapView: View {
    var rescueModel: MapViewModel
    var loginModel: LoginViewModel
    
    var mapView = MKMapView()
    
    @State var currentLocation = MapModel.Location(
        id: "",
        username: "",
        title: "",
        description: "",
        image: UIImage(imageLiteralResourceName: "denero"),
        tags: "",
        coordinate: CLLocationCoordinate2D(latitude: 37.871684, longitude: -122.259934),
        radius: 10
    )
    @State var showingDetail = false
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.871684, longitude: -122.259934), span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))

    var body: some View {
        NavigationView {
            ZStack {
                Map(coordinateRegion: $region, annotationItems: MapDataSource.shared.locations) { location in
                    MapAnnotation(coordinate: location.coordinate) {
                        MarkerView(showingDetail: $showingDetail, currentLocation: $currentLocation, location: location)
                    }
                }.ignoresSafeArea()
                if showingDetail {
                    SmallCardView(location: currentLocation, showingDetail: $showingDetail).offset(y: UIScreen.main.bounds.size.height / 2 - 200)
                }
            }
        }
    }
}
//
//struct Location: Identifiable {
//    var message: String = ""
//    var timeStamp: String = ""
//    var photo: Image = Image("denero")
//    var petType: String = ""
//    var zip : String = ""
//    var id = UUID()
//    var name = ""
//    var coordinate = CLLocationCoordinate2D(latitude: 37.871684, longitude: -122.259934)
//}
struct MarkerView: View {
    @Binding var showingDetail: Bool
    @Binding var currentLocation: MapModel.Location
    var location: MapModel.Location
    var body: some View {
        
        ZStack {
            Button(action: {
                self.showingDetail = true
                currentLocation = location
            }) {
                Image(uiImage: location.image).resizable().frame(width: 40, height: 40).clipShape(Circle())
            }
        }
    }
}

struct SmallCardView: View {
    var location: MapModel.Location
    @Binding var showingDetail: Bool
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.white)
                .frame(width: UIScreen.main.bounds.size.width - 50, height: 160)
            HStack {
                Image(uiImage: location.image)
                    .resizable()
                    .aspectRatio(1.0, contentMode: .fit)
                    .clipped()
                    .frame(width: 125, height: 125)
                    .cornerRadius(10)
                VStack {
                    Text(location.title)
                    Text("Owner: Kelsey \n  Contact: (510)747-2639 \n  Male, 4 yrs, 6 lbs, caramel")
                }
                NavigationLink(
                    destination:
                        DetailedCardView(location: location)) {
                            Text(">>>").foregroundColor(.blue)
                  }
            }
//            Text(location.title).foregroundColor(.black)
            Button(action: {
                self.showingDetail = false
            }) {
                Image(systemName: "multiply").resizable()
                    .frame(width: 20.0, height: 20.0).foregroundColor(.black)
            }.offset(x: 165, y: -55)
        }
    }
}

struct DetailedCardView: View {
    var location: MapModel.Location

    var body: some View {
        VStack {
            Image(uiImage: location.image).resizable().aspectRatio(1.0, contentMode: .fit)
            Text("Title: " + location.title)
        }
    }
    // TODO: Resize image

    func convertToDate(timeStamp: String) -> String {
        let date = NSDate(timeIntervalSince1970: Double(timeStamp)!)
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy HH:mm:ss"
        let dateString = formatter.string(from: date as Date)
        return dateString
    }
}

//struct NewLocationButton: View {
//    var loginModel: LoginViewModel
//    var rescueModel: MapViewModel
//    var body: some View {
//        penIcon.frame(alignment: Alignment.topTrailing)
//        Spacer()
//    }
//    
//    var penIcon: some View {
//        Button(action: { }, label: {
//            NavigationLink(destination: NewLocationView(rescueModel: rescueModel, loginModel: loginModel)) {
//                Image(systemName: "square.and.pencil").foregroundColor(Color("logo-pink")).padding().font(.system(size: 25))
//            }
//        })
//    }
//}
//
//struct NewLocationView: View {
//    var rescueModel: MapViewModel
//    var loginModel: LoginViewModel
//
//    @State private var title: String = ""
//    @State private var description: String = ""
//    @State private var petType: String = ""
//    @State private var zip: String = ""
//    @State private var name: String = ""
//    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
//    @State private var selectedImage = UIImage(named: "cat-portrait")
//    @State private var isImagePickerDisplay = false
//
//    var theregion = MKCoordinateRegion(
//            center: CLLocationCoordinate2D(latitude: 37.334_900,
//                                           longitude: -122.009_020),
//            latitudinalMeters: 750,
//            longitudinalMeters: 750
//        )
//
//
//    var body: some View {
//        Form {
//            Section(header: Text("Title")) {
//                TextField("Enter title...", text: $title, onEditingChanged: { (changed) in
//                    print("title onEditingChanged - \(changed)")
//                })
//            }
//
//            Section(header: Text("Description")) {
//                TextField("Enter description...", text: $description, onEditingChanged: { (changed) in
//                    print("description onEditingChanged - \(changed)")
//                })
//            }
//
//            Section(header: Text("Image")) {
//                Button("Camera") {
//                    self.sourceType = .camera
//                    self.isImagePickerDisplay.toggle()
//                }
//                Button("Photo") {
//                    self.sourceType = .photoLibrary
//                    self.isImagePickerDisplay.toggle()
//                }
//            }
//
//            Section(header: Text("Tags")) {
//                Button(action: { }, label: {
//                    NavigationLink(destination: MapTestView(place: [IdentifiablePlace(lat: 37.334_90, long: -122.009_020)], region: theregion)) {
//                        Image(systemName: "square.and.pencil").foregroundColor(Color("logo-pink")).padding().font(.system(size: 25))
//                    }
//                })
//            }
//            Button(action: { addLocation(message: description, photo: selectedImage!, petType: petType, zip: zip, name: name, coordinate: CLLocationCoordinate2D(latitude: 37.881684, longitude: -122.269934), username: loginModel.getEmail(), title: title)}, label: {Text("Publish Post").foregroundColor(Color("logo-pink")).font(.system(size: 20));
//                        }).padding(.trailing).buttonStyle(.bordered).foregroundColor(Color("logo-pink")).sheet(isPresented: self.$isImagePickerDisplay) {
//                            ImagePickerView(selectedImage: self.$selectedImage, sourceType: self.sourceType)
//                        }
//        }.navigationTitle("Add Post")
//    }
//
//    func addLocation(message: String, photo: UIImage, petType: String, zip: String, name: String, coordinate: CLLocationCoordinate2D, username: String, title: String) {
//        rescueModel.addLocation(message: message, photo: photo, petType: petType, zip: zip, name: name, coordinate: coordinate, username: username, title: title)
//    }
//}

struct RescueView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(rescueModel: MapViewModel(), loginModel: LoginViewModel())
    }
}
