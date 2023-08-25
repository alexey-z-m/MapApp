//
//  ViewController.swift
//  MapApp
//
//  Created by Alexey Zablotskiy on 24.08.2023.
//

import UIKit
import YandexMapsMobile
import SnapKit
import CoreLocation

class ViewController: UIViewController {

    let currentLocation = CLLocationManager()
    var currentLatitude: CLLocationDegrees = 55.753921
    var currentLongitude: CLLocationDegrees = 37.620709
    var curentPointId: Int?
    let arrayPoints = [
        1:YMKPoint(latitude: 55.753, longitude: 37.620709),
        2:YMKPoint(latitude: 55.757, longitude: 37.620709),
        3:YMKPoint(latitude: 55.761, longitude: 37.620709)
    ]

    lazy var bottomView = BottomView()
    lazy var mapView = MapView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarchy()
        setupLayout()
        mapView.zoomInButton.addTarget(self, action: #selector(zoom), for: .touchUpInside)
        mapView.zoomOutButton.addTarget(self, action: #selector(zoom), for: .touchUpInside)
        mapView.locationButton.addTarget(self, action: #selector(getMyLocation), for: .touchUpInside)
        mapView.nextTrackerButton.addTarget(self, action: #selector(nextTracker), for: .touchUpInside)
    }

    func setupHierarchy() {
        view.addSubview(mapView)
        mapView.addSubview(bottomView)
    }

    func setupLayout() {
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        bottomView.isHidden = true
        bottomView.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalToSuperview()
            make.height.equalTo(200)
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

        currentLocation.requestWhenInUseAuthorization()
        currentLocation.delegate = self
        currentLocation.startUpdatingLocation()

        mapView.mapYMK.mapWindow.map.move(
            with: YMKCameraPosition.init(target: YMKPoint(latitude: 55.753921, longitude: 37.620709), zoom: 14, azimuth: 0, tilt: 0),
            animationType: YMKAnimation(type: YMKAnimationType.smooth, duration: 2))

        addTestPlacemarks()
    }

    @objc func zoom(sender: UIButton) {
        let zoomStep: Float = sender.tag == 0 ? -1 : 1
        let center = mapView.mapYMK.mapWindow.map.cameraPosition.target
        let position = YMKCameraPosition(target: center, zoom: mapView.mapYMK.mapWindow.map.cameraPosition.zoom + zoomStep, azimuth: 0, tilt: 0)
        mapView.mapYMK.mapWindow.map.move(with: position, animationType: YMKAnimation(type: YMKAnimationType.smooth, duration: 0.5))
    }

    @objc func getMyLocation(sender: UIButton) {
        let myPoint = YMKPoint(latitude: currentLatitude, longitude: currentLongitude)
        mapView.mapYMK.mapWindow.map.move(
            with: YMKCameraPosition.init(target: myPoint, zoom: 15, azimuth: 0, tilt: 0),
            animationType: YMKAnimation(type: YMKAnimationType.smooth, duration: 4))

        addPlacemark(point: myPoint, image: UIImage(named: "my_tracker")!)
    }

    @objc func nextTracker(sender: UIButton) {
        if let id = curentPointId {
            if id < arrayPoints.count {
                self.focusOnPoint(arrayPoints[id + 1]!)
                curentPointId = id + 1
            } else {
                self.focusOnPoint(arrayPoints[1]!)
                curentPointId = 1
            }
        }
        else {
            self.focusOnPoint(arrayPoints[1]!)
            curentPointId = 1
        }
    }

    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        if !bottomView.frame.contains(location) {
            bottomView.isHidden = true
        }
    }

    func addPlacemark(point: YMKPoint, image: UIImage) {
        let viewPlacemark: YMKPlacemarkMapObject = mapView.mapYMK.mapWindow.map.mapObjects.addPlacemark(with: point)
        viewPlacemark.setIconWith(
            image.resized(to: CGSize(width: 50, height: 50))
        )
        viewPlacemark.addTapListener(with: self)
    }

    func mergeImages(imageView: UIImageView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(imageView.frame.size, false, 0.0)
        imageView.superview!.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    func addTestPlacemarks() {
        arrayPoints.forEach { index, point in
            addPlacemark(point: point, image: UIImage(named: "tracker")!.mergeWith(topImage: UIImage(named: "photo\(index)")!))
        }
    }
    
    func details() {
        bottomView.isHidden = false
        guard let id = curentPointId else { return }
        bottomView.imagePhoto.image = UIImage(named: "photo\(id)")
    }
}

extension ViewController: YMKMapObjectTapListener {
    func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
        guard let placemark = mapObject as? YMKPlacemarkMapObject else {
            return false
        }
        self.focusOnPoint(placemark.geometry)
        return true
    }

    func focusOnPoint(_ point: YMKPoint) {
        curentPointId = arrayPoints.first(where: {
            $0.value.latitude == point.latitude &&
            $0.value.longitude == point.longitude
        })?.key
        mapView.mapYMK.mapWindow.map.move(
            with: YMKCameraPosition(target: point, zoom: 15, azimuth: 0, tilt: 0),
            animationType: YMKAnimation(type: YMKAnimationType.smooth, duration: 1)
        )
        details()
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            currentLocation.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let locationSafe = locations.last {
            currentLocation.stopUpdatingLocation()
            let latitude = locationSafe.coordinate.latitude
            let longitude = locationSafe.coordinate.longitude
            self.currentLatitude = latitude
            self.currentLongitude = longitude
            print(" Latitude \(latitude) ,  Longitude \(longitude)")
        }

        if locations.first != nil {
            print("location:: \(locations[0])")
        }
    }
}

extension UIImage {
    func mergeWith(topImage: UIImage) -> UIImage {
        let bottomImage = self
        UIGraphicsBeginImageContext(size)
        let bottomImageAreaSize = CGRect(x: 0, y: 0, width: bottomImage.size.width, height: bottomImage.size.height)
        bottomImage.draw(in: bottomImageAreaSize)
        let topImageAreaSize = CGRect(x: 40, y: 25, width: bottomImage.size.width - 80, height: bottomImage.size.height - 80)
        topImage.draw(in: topImageAreaSize, blendMode: .sourceAtop, alpha: 1.0)
        let mergedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return mergedImage
    }

    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

