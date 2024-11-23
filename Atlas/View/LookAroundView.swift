
import SwiftUI
import MapKit

struct LookAroundView: UIViewControllerRepresentable {
    @Binding var scene: MKLookAroundScene
    
    func makeUIViewController(context: Context) -> MKLookAroundViewController {
        let viewController = MKLookAroundViewController(scene: scene)
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: MKLookAroundViewController, context: Context) {
        uiViewController.scene = scene
    }
}