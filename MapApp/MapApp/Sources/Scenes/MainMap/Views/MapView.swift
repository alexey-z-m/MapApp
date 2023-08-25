//
//  MapView..swift
//  MapApp
//
//  Created by Alexey Zablotskiy on 25.08.2023.
//

import UIKit
import SnapKit
import YandexMapsMobile

class MapView: UIView {

    lazy var mapYMK: YMKMapView = {
        let map = YMKMapView()
        return map
    }()
    
    lazy var zoomInButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "zoom_plus"), for: .normal)
        button.tag = 1
        return button
    }()

    lazy var zoomOutButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "zoom_minus"), for: .normal)
        button.tag = 0
        return button
    }()

    lazy var locationButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "my_location"), for: .normal)
        button.tag = 0
        return button
    }()

    lazy var nextTrackerButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "next_tracker"), for: .normal)
        button.tag = 0
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHierarchy()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func setupHierarchy() {
        addSubview(mapYMK)
        mapYMK.addSubview(zoomInButton)
        mapYMK.addSubview(zoomOutButton)
        mapYMK.addSubview(locationButton)
        mapYMK.addSubview(nextTrackerButton)
    }

    func setupLayout() {
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
    }
}
