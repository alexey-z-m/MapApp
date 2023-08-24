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

        addPlacemarkOnMap()
    }

    @objc func zoom(sender: UIButton) {
        let zoomStep: Float = sender.tag == 0 ? -1 : 1
        let center = mapView.mapWindow.map.cameraPosition.target
        let position = YMKCameraPosition(target: center, zoom: mapView.mapWindow.map.cameraPosition.zoom + zoomStep, azimuth: 0, tilt: 0)
        mapView.mapWindow.map.move(with: position, animationType: YMKAnimation(type: YMKAnimationType.smooth, duration: 0.5), cameraCallback: nil)
    }
    @objc func getMyLocation(sender: UIButton) {
        mapView.mapWindow.map.move(
            with: YMKCameraPosition.init(target: YMKPoint(latitude: currentLatitude, longitude: currentLongitude), zoom: 15, azimuth: 0, tilt: 0),
            animationType: YMKAnimation(type: YMKAnimationType.smooth, duration: 4),
            cameraCallback: nil)
    }
    @objc func nextTracker(sender: UIButton) {

    }

    func addPlacemarkOnMap() {
        let arrayPoints = [
            YMKPoint(latitude: 55.753, longitude: 37.620709),
            YMKPoint(latitude: 55.757, longitude: 37.620709),
            YMKPoint(latitude: 55.761, longitude: 37.620709)
        ]
        arrayPoints.forEach { point in
            let viewPlacemark: YMKPlacemarkMapObject = mapView.mapWindow.map.mapObjects.addPlacemark(with: point)

            viewPlacemark.setIconWith(
                UIImage(named: "tracker")!,
                style: YMKIconStyle(
                    anchor: CGPoint(x: 0.5, y: 0.5) as NSValue,
                    rotationType: YMKRotationType.rotate.rawValue as NSNumber,
                    zIndex: 0,
                    flat: true,
                    visible: true,
                    scale: 0.2,
                    tappableArea: nil
                )
            )
            viewPlacemark.addTapListener(with: self)
        }
    }
    func details() {
        mapView.addSubview(im)
        im.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-50)
        }
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

