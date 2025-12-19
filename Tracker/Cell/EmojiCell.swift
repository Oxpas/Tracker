//
//  EmojiCell.swift
//  Tracker
//
//  Created by Николай Замараев on 24.11.2025.
//
import UIKit

final class EmojiCell: UICollectionViewCell {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    lazy var emojiLabel: UILabel = {
        let label = UILabel()
        
        label.font = UIFont.systemFont(ofSize: 32)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var emojiContainer: UIView = {
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    private func setupUI() {
        contentView.addSubview(emojiContainer)
        emojiContainer.addSubview(emojiLabel)
        
        NSLayoutConstraint.activate([
            emojiContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            emojiContainer.widthAnchor.constraint(equalToConstant: 52),
            emojiContainer.heightAnchor.constraint(equalToConstant: 52),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiContainer.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiContainer.centerYAnchor)
        ])
    }
    
    func setSelected(_ isSelected: Bool) {
        if isSelected {
            emojiContainer.backgroundColor = traitCollection.userInterfaceStyle == .light ? UIColor.lightGray.withAlphaComponent(0.3) : .white
        } else {
            emojiContainer.backgroundColor = .clear
        }
    }
}


