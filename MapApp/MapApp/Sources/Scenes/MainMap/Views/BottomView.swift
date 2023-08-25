//
//  BottomView.swift
//  MapApp
//
//  Created by Alexey Zablotskiy on 25.08.2023.
//

import UIKit
import SnapKit

class BottomView: UIView {

    let bottomPanel: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0.0, height: -2.0)
        view.layer.shadowRadius = 3.0
        view.layer.shadowOpacity = 0.1
        view.layer.masksToBounds = false
        return view
    }()

    let imagePhoto: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "photo1")
        image.layer.cornerRadius = image.frame.size.width / 2
        return image
    }()

    let hStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillProportionally
        stack.spacing = 10
        return stack
    }()

    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name"
        label.font = .systemFont(ofSize: 17, weight: .bold)
        return label
    }()
    let gpsLabel: UILabel = {
        let label = UILabel()
        let img = NSTextAttachment()
        img.image = UIImage(systemName: "wifi")?.withTintColor(.blue)
        let fullString = NSMutableAttributedString(string: "GPS")
        fullString.insert(NSAttributedString(attachment: img),at: 0)
        label.attributedText = fullString
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let dataLabel : UILabel = {
        let label = UILabel()
        let img = NSTextAttachment()
        img.image = UIImage(systemName: "calendar")?.withTintColor(.blue)
        let fullString = NSMutableAttributedString(string: "02.07.17")
        fullString.insert(NSAttributedString(attachment: img),at: 0)
        label.attributedText = fullString
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let timeLabel: UILabel = {
        let label = UILabel()
        let img = NSTextAttachment()
        img.image = UIImage(systemName: "clock")?.withTintColor(.blue)
        let fullString = NSMutableAttributedString(string: "14:00")
        fullString.insert(NSAttributedString(attachment: img),at: 0)
        label.attributedText = fullString
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let button: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 25
        button.setTitle("Посмотреть историю", for: .normal)
        button.tintColor = .white
        button.backgroundColor = .blue
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
        addSubview(bottomPanel)
        bottomPanel.addSubview(imagePhoto)
        bottomPanel.addSubview(nameLabel)
        bottomPanel.addSubview(hStack)
        hStack.addArrangedSubview(gpsLabel)
        hStack.addArrangedSubview(dataLabel)
        hStack.addArrangedSubview(timeLabel)
        bottomPanel.addSubview(button)
    }
    func setupLayout() {
        bottomPanel.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(200)
        }

        imagePhoto.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(30)
            make.height.width.equalTo(70)
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.leading.equalTo(imagePhoto.snp.trailing).offset(20)
        }

        hStack.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(10)
            make.leading.equalTo(imagePhoto.snp.trailing).offset(20)
        }

        button.snp.makeConstraints { make in
            make.top.equalTo(hStack.snp.bottom).offset(20)
            make.leading.equalTo(imagePhoto.snp.trailing).offset(20)
            make.height.equalTo(50)
            make.width.equalTo(200)
        }
    }
}
