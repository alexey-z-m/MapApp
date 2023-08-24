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

    var curentPointId: Int?
    let arrayPoints = [
        1:YMKPoint(latitude: 55.753, longitude: 37.620709),
        2:YMKPoint(latitude: 55.757, longitude: 37.620709),
        3:YMKPoint(latitude: 55.761, longitude: 37.620709)
    ]

    let currentLocation = CLLocationManager()
    var currentLatitude: CLLocationDegrees = 55.753921
    var currentLongitude: CLLocationDegrees = 37.620709

    lazy var zoomInButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "zoom_plus"), for: .normal)
        button.tag = 1
        button.addTarget(self, action: #selector(zoom), for: .touchUpInside)
        return button
    }()

    lazy var zoomOutButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "zoom_minus"), for: .normal)
        button.tag = 0
        button.addTarget(self, action: #selector(zoom), for: .touchUpInside)
        return button
    }()

    lazy var locationButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "my_location"), for: .normal)
        button.tag = 0
        button.addTarget(self, action: #selector(getMyLocation), for: .touchUpInside)
        return button
    }()

    lazy var nextTrackerButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "next_tracker"), for: .normal)
        button.tag = 0
        button.addTarget(self, action: #selector(nextTracker), for: .touchUpInside)
        return button
    }()

    let im: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "person")
        return image
    }()

    lazy var mapView: YMKMapView = {
        let map = YMKMapView()
        return map
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        currentLocation.requestWhenInUseAuthorization()
        currentLocation.delegate = self
        currentLocation.startUpdatingLocation()

        view.addSubview(mapView)
        mapView.addSubview(zoomInButton)
        mapView.addSubview(zoomOutButton)
        mapView.addSubview(locationButton)
        mapView.addSubview(nextTrackerButton)

        mapView.snp.makeConstraints { make in
            make.top.trailing.bottom.leading.equalToSuperview()
        }

        zoomInButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.trailing.equalToSuperview().offset(-20)
            make.width.height.equalTo(50)
        }

        zoomOutButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(160)
            make.trailing.equalToSuperview().offset(-20)
            make.width.height.equalTo(50)
        }

        locationButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(220)
            make.trailing.equalToSuperview().offset(-20)
            make.width.height.equalTo(50)
        }

        nextTrackerButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(280)
            make.trailing.equalToSuperview().offset(-20)
            make.width.height.equalTo(50)
        }

        mapView.mapWindow.map.move(
            with: YMKCameraPosition.init(target: YMKPoint(latitude: 55.753921, longitude: 37.620709), zoom: 14, azimuth: 0, tilt: 0),
            animationType: YMKAnimation(type: YMKAnimationType.smooth, duration: 2),
            cameraCallback: nil)

        addTestPlacemarks()
    }

    @objc func zoom(sender: UIButton) {
        let zoomStep: Float = sender.tag == 0 ? -1 : 1
        let center = mapView.mapWindow.map.cameraPosition.target
        let position = YMKCameraPosition(target: center, zoom: mapView.mapWindow.map.cameraPosition.zoom + zoomStep, azimuth: 0, tilt: 0)
        mapView.mapWindow.map.move(with: position, animationType: YMKAnimation(type: YMKAnimationType.smooth, duration: 0.5), cameraCallback: nil)
    }
    @objc func getMyLocation(sender: UIButton) {
        let myPoint = YMKPoint(latitude: currentLatitude, longitude: currentLongitude)
        mapView.mapWindow.map.move(
            with: YMKCameraPosition.init(target: myPoint, zoom: 15, azimuth: 0, tilt: 0),
            animationType: YMKAnimation(type: YMKAnimationType.smooth, duration: 4),
            cameraCallback: nil)

        addPlacemark(point: myPoint, image: UIImage(named: "my_tracker")!)
    }
    @objc func nextTracker(sender: UIButton) {
        if let id = curentPointId {
            if id < arrayPoints.count {
                let placemark: YMKPlacemarkMapObject = mapView.mapWindow.map.mapObjects.addPlacemark(with: arrayPoints[id + 1]!)
                self.focusOnPlacemark(placemark)
                curentPointId = id + 1
            } else {
                let placemark: YMKPlacemarkMapObject = mapView.mapWindow.map.mapObjects.addPlacemark(with: arrayPoints[1]!)
                self.focusOnPlacemark(placemark)
                curentPointId = 1
            }
        }
        else {
            let placemark: YMKPlacemarkMapObject = mapView.mapWindow.map.mapObjects.addPlacemark(with: arrayPoints[1]!)
            self.focusOnPlacemark(placemark)
            curentPointId = 1
        }
    }

    func addPlacemark(point: YMKPoint, image: UIImage) {
        let viewPlacemark: YMKPlacemarkMapObject = mapView.mapWindow.map.mapObjects.addPlacemark(with: point)
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

    }
}

extension ViewController: YMKMapObjectTapListener {
    func onMapObjectTap(with mapObject: YMKMapObject, point: YMKPoint) -> Bool {
        guard let placemark = mapObject as? YMKPlacemarkMapObject else {
            return false
        }
        self.focusOnPlacemark(placemark)

        return true
    }

    func focusOnPlacemark(_ placemark: YMKPlacemarkMapObject) {
        mapView.mapWindow.map.move(
            with: YMKCameraPosition(target: placemark.geometry, zoom: 15, azimuth: 0, tilt: 0),
            animationType: YMKAnimation(type: YMKAnimationType.smooth, duration: 1),
            cameraCallback: nil
        )
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

