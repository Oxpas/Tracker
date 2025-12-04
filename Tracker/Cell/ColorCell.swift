//
//  ColorCell.swift
//  Tracker
//
//  Created by Николай Замараев on 24.11.2025.
//

import UIKit

final class ColorCell: UICollectionViewCell {
    
    private lazy var colorView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var selectionBorder: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 13
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.clear.cgColor
        view.isHidden = true
        view.backgroundColor = .clear
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    private func setupUI() {
        layer.cornerRadius = 0
        layer.masksToBounds = false
        
        contentView.addSubview(colorView)
        contentView.addSubview(selectionBorder)
        
        NSLayoutConstraint.activate([
            selectionBorder.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            selectionBorder.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            selectionBorder.widthAnchor.constraint(equalToConstant: 52),
            selectionBorder.heightAnchor.constraint(equalToConstant: 52),
            
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func configure(with color: UIColor) {
        colorView.backgroundColor = color
    }
    
    func setSelected(_ isSelected: Bool, with color: UIColor) {
        if isSelected {
            selectionBorder.isHidden = false
            selectionBorder.layer.borderColor = color.withAlphaComponent(0.3).cgColor
        } else {
            selectionBorder.isHidden = true
            selectionBorder.layer.borderColor = UIColor.clear.cgColor
        }
    }
}
