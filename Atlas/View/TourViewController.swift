import SwiftUI
import MapKit
import CoreLocation

struct TourView: View {
    @State private var mapView = MKMapView()
    @State private var lookAroundViewController = MKLookAroundViewController()
    @State private var currentStopIndex: Int? = nil
    @State private var mapRouteResults = MapDataResults<MapRouteID, MKRoute?>()
    @State private var itinerary: Itinerary!
    @State private var titleLabel: String = ""
    @State private var showNextButton: Bool = false
    @State private var showTitleEffectView: Bool = false
    @State private var showLookAroundContainerView: Bool = false

    var body: some View {
        VStack {
            MapView(mapView: $mapView)
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    setupMapView()
                    if currentStopIndex == nil {
                        currentStopIndex = 0
                        guard currentStopIndex! < itinerary.stops.count else {
                            configureArrival(at: currentStopIndex!)
                            return
                        }
                        animateArrival(at: currentStopIndex!, afterDelay: 1)
                    }
                }
            if showTitleEffectView {
                Text(titleLabel)
                    .font(.title)
                    .padding()
                    .background(VisualEffectView(effect: UIBlurEffect(style: .light)))
            }
            if showLookAroundContainerView {
                LookAroundView(lookAroundViewController: $lookAroundViewController)
                    .frame(height: 200)
            }
            if showNextButton {
                Button(action: goToNextStop) {
                    HStack {
                        Text(currentStopIndex! + 1 >= itinerary.stops.count ? "Close" : "Next")
                        Image(systemName: currentStopIndex! + 1 >= itinerary.stops.count ? "xmark.circle.fill" : "arrow.forward.circle.fill")
                    }
                }
                .padding()
            }
        }
    }

    private func setupMapView() {
        let centerOfLisbon = CLLocationCoordinate2D(latitude: 38.7223, longitude: -9.1393)
        mapView.region = MKCoordinateRegion(center: centerOfLisbon, latitudinalMeters: 20_000, longitudinalMeters: 20_000)
        let boundaryRegion = MKCoordinateRegion(center: centerOfLisbon, latitudinalMeters: 40_000, longitudinalMeters: 40_000)
        mapView.cameraBoundary = MKMapView.CameraBoundary(coordinateRegion: boundaryRegion)
        let zoomRange = MKMapView.CameraZoomRange(minCenterCoordinateDistance: 100, maxCenterCoordinateDistance: 40_000)
        mapView.cameraZoomRange = zoomRange
        mapView.preferredConfiguration = MKStandardMapConfiguration(elevationStyle: .realistic)
    }

    private func goToNextStop() {
        guard showNextButton else { return }
        guard currentStopIndex! + 1 < itinerary.stops.count else {
            // Close the view
            return
        }
        withAnimation {
            showNextButton = false
            showLookAroundContainerView = false
        }
        animateTravel(from: currentStopIndex!)
        currentStopIndex! += 1
    }

    /// Animate the arrival at the stop with the given index.
    private func animateArrival(at stopIndex: Int, afterDelay delay: Double = 0) {
        guard stopIndex < itinerary.stops.count else { return }
        let stop = itinerary.stops[stopIndex]
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(.easeInOut(duration: 3)) {
                mapView.camera = MKMapCamera(lookingAt: stop.mapItem, forViewSize: mapView.bounds.size, allowPitch: true)
            }
            configureArrival(at: stopIndex)
        }
    }

    private func configureArrival(at stopIndex: Int) {
        if stopIndex + 1 >= itinerary.stops.count {
            showNextButton = true
        }
        guard stopIndex < itinerary.stops.count else {
            showLookAroundContainerView = false
            showNextButton = true
            return
        }
        let stop = itinerary.stops[stopIndex]
        if stopIndex + 1 < itinerary.stops.count {
            let nextStop = itinerary.stops[stopIndex + 1]
            prepareMapRoute(from: stop, to: nextStop)
        }
        withAnimation {
            titleLabel = stop.title
            showTitleEffectView = true
            showNextButton = true
        }
        Task {
            let lookAroundScene: MKLookAroundScene?
            do {
                lookAroundScene = try await itinerary.lookAroundScene(for: stop.mapItemID)
            } catch {
                lookAroundScene = nil
            }
            if let lookAroundScene = lookAroundScene {
                lookAroundViewController.scene = lookAroundScene
                withAnimation {
                    showLookAroundContainerView = true
                }
            }
        }
    }

    private func animateTravel(from stopIndex: Int) {
        let currentStop = itinerary.stops[stopIndex]
        let nextStop = itinerary.stops[stopIndex + 1]
        mapView.removeOverlays(mapView.overlays)
        withAnimation {
            titleLabel = ""
            showTitleEffectView = false
        }
        Task {
            let mapRoute: MKRoute?
            do {
                mapRoute = try await preparedMapRoute(from: currentStop, to: nextStop)
            } catch {
                mapRoute = nil
            }
            if let mapRoute = mapRoute {
                mapView.addOverlay(mapRoute.polyline)
                withAnimation(.easeInOut(duration: 3)) {
                    let insets = UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30)
                    let startDestination = MKMapRect(origin: MKMapPoint(currentStop.coordinate), size: MKMapSize(width: 1, height: 1))
                    let navigationVisibleRect = mapRoute.polyline.boundingMapRect.union(startDestination)
                    mapView.setVisibleMapRect(navigationVisibleRect, edgePadding: insets, animated: true)
                }
                withAnimation(.easeInOut(duration: 3)) {
                    let pointCount = mapRoute.polyline.pointCount
                    let lastPoint = mapRoute.polyline.points()[pointCount - 1]
                    mapView.camera = MKMapCamera(lookingAtCenter: lastPoint.coordinate, fromDistance: 1500, pitch: 60, heading: 0)
                }
                animateArrival(at: stopIndex + 1)
            } else {
                animateArrival(at: stopIndex + 1)
            }
        }
    }

    private func preparedMapRoute(from startingStop: ItineraryStop, to endingStop: ItineraryStop) async throws -> MKRoute? {
        let mapRouteID = MapRouteID(startItemID: startingStop.mapItemID, endItemID: endingStop.mapItemID)
        return try await mapRouteResults.preloadedResult(for: mapRouteID).get()
    }

    private func prepareMapRoute(from startingStop: ItineraryStop, to endingStop: ItineraryStop) {
        let mapRouteID = MapRouteID(startItemID: startingStop.mapItemID, endItemID: endingStop.mapItemID)
        guard mapRouteResults.availableResult(for: mapRouteID) == nil else { return }
        Task {
            _ = await mapRouteResults.result(for: mapRouteID) {
                let directionsRequest = MKDirections.Request()
                directionsRequest.source = startingStop.mapItem
                directionsRequest.destination = endingStop.mapItem
                directionsRequest.transportType = .automobile
                let directionsService = MKDirections(request: directionsRequest)
                let response = try await directionsService.calculate()
                let route = response.routes.first
                return route
            }
        }
    }
}

struct MapView: UIViewRepresentable {
    @Binding var mapView: MKMapView

    func makeUIView(context: Context) -> MKMapView {
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let overlay = overlay as? MKPolyline else {
                fatalError("Unexpected overlay \(overlay) added to the map view")
            }
            let renderer = MKPolylineRenderer(polyline: overlay)
            renderer.strokeColor = .tintColor
            renderer.lineWidth = 6
            return renderer
        }
    }
}

struct LookAroundView: UIViewControllerRepresentable {
    @Binding var lookAroundViewController: MKLookAroundViewController

    func makeUIViewController(context: Context) -> MKLookAroundViewController {
        return lookAroundViewController
    }

    func updateUIViewController(_ uiViewController: MKLookAroundViewController, context: Context) {}
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?

    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: effect)
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = effect
    }
}
