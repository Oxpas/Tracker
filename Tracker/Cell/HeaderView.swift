//
//  HeaderView.swift
//  Tracker
//
//  Created by Николай Замараев on 02.11.2025.
//
import UIKit

final class HeaderView: UICollectionReusableView {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label.textColor = traitCollection.userInterfaceStyle == .light ? .ypBlackDay : .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    private func setupUI() {
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func configure(with title: String) {
        titleLabel.text = title
        titleLabel.textColor = traitCollection.userInterfaceStyle == .light ? .ypBlackDay : .white
    }
}
