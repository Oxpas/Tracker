//
//  TrackerCell.swift
//  Tracker
//
//  Created by Николай Замараев on 26.10.2025.
//

import Foundation
import UIKit

final class TrackerCell: UICollectionViewCell {
    
    private var trackerID: UUID?
    var doneButtonTapped: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var name: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
//        label.textAlignment = .center
        label.textColor = .white
//        label.layer.cornerRadius = 12
        label.translatesAutoresizingMaskIntoConstraints = false
//        label.clipsToBounds = true
//        label.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        label.numberOfLines = 2
        
        return label
    }()
    
    private lazy var day: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(named: "YP BlackDay")
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var emoji: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var color: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 17
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addAction(UIAction {[weak self] _ in
            self?.doneButtonTapped?()
        }, for: .touchUpInside)
        
        return button
    }()
    
    private func setupUI() {
        contentView.addSubview(color)
        contentView.addSubview(emoji)
        contentView.addSubview(day)
        contentView.addSubview(name)
        contentView.addSubview(doneButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            name.leadingAnchor.constraint(equalTo: color.leadingAnchor, constant: 12),
            name.trailingAnchor.constraint(equalTo: color.trailingAnchor, constant: -12),
            name.bottomAnchor.constraint(equalTo: color.bottomAnchor, constant: -12),
            
            emoji.topAnchor.constraint(equalTo: color.topAnchor, constant: 12),
            emoji.leadingAnchor.constraint(equalTo: color.leadingAnchor, constant: 12),
            emoji.widthAnchor.constraint(equalToConstant: 24),
            emoji.heightAnchor.constraint(equalToConstant: 24),
            
            day.topAnchor.constraint(equalTo: color.bottomAnchor, constant: 16),
            day.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            
            color.topAnchor.constraint(equalTo: contentView.topAnchor),
            color.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            color.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            color.heightAnchor.constraint(equalToConstant: 90),
            
            doneButton.topAnchor.constraint(equalTo: color.bottomAnchor, constant: 8),
            doneButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            doneButton.widthAnchor.constraint(equalToConstant: 34),
            doneButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    func configure(with tracker: Tracker, completedDays: Int, isCompletedToday: Bool) {
        trackerID = tracker.id
        color.backgroundColor = tracker.color
        emoji.text = tracker.emoji
        name.text = tracker.name
        
        let dayString = nameOfDaysFormatter(count: completedDays)
        day.text = dayString
        
        updateCompleteButton(isCompletedToday: isCompletedToday, color: tracker.color)
        
        
    }
    
    private func nameOfDaysFormatter(count: Int) -> String {
        let remainder10 = count % 10
        let remainder100 = count % 100
        
        if remainder10 == 1 && remainder100 != 11 {
            return "\(count) день"
        } else if remainder10 >= 2 && remainder10 <= 4 && (remainder100 < 10 || remainder100 >= 20) {
            return "\(count) дня"
        } else {
            return "\(count) дней"
        }
    }
    
    func updateCompleteButton(isCompletedToday: Bool, color: UIColor) {
        if isCompletedToday {
            doneButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            doneButton.tintColor = color
            doneButton.backgroundColor = color.withAlphaComponent(0.3)
        } else {
            doneButton.setImage(UIImage(systemName: "plus"), for: .normal)
            doneButton.tintColor = .white
            doneButton.backgroundColor = color
        }
    }
    
    
    }
