//
//  SecondViewController.swift
//  Tracker
//
//  Created by Николай Замараев on 24.10.2025.
//

import UIKit

struct Card {
    let number: Int
    let text: String
}

final class StatisticViewController: UIViewController {
    
    private var trackerStore: TrackerStore?
    private var trackersCompletedCount: Int = 0
    private var perfectDays: Int = 0
    private var longestStreak: Int = 0
    private var averageTracker: Int = 0
    
    private lazy var trackerRecordStore: TrackerRecordStore = {
        let context = DataService.shared.context
        let store = TrackerRecordStore(context: context)
        return store
    }()
    
    private var gradientBorders: [UIView] = []
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("statistics_label", comment: "StatisticViewController")
        label.font = UIFont.boldSystemFont(ofSize: 34)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var imagePlaceholder: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(resource: .statisticPlaceholder)
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private lazy var textPlaceholder: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("statistic_text_placeholder", comment: "StatisticViewController")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    private lazy var placeholderView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imagePlaceholder, textPlaceholder])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var mainCardStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupCards()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupCards()
        updatePlaceholderVisible()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateAllGradientFrames()
    }
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(mainCardStack)
        view.addSubview(placeholderView)
        
        view.backgroundColor = .systemBackground
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1),
            
            mainCardStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 77),
            mainCardStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            mainCardStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            placeholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
        ])
    }
    
    private func updatePlaceholderVisible() {
        let hasTrackers = trackerStore?.fetchTrackers().count
        
        if hasTrackers == 0 {
            placeholderView.isHidden = false
        } else {
            placeholderView.isHidden = true
        }
    }
    
    private func createCardStack(number: Int, text: String) -> UIView {
        // Контейнер для всей карточки
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .clear
        
        // Внутренняя часть карточки
        let cardView = UIView()
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.layer.cornerRadius = 16
        cardView.clipsToBounds = true
        
        // Стек для текста
        let numberLabel = UILabel()
        numberLabel.text = "\(number)"
        numberLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        numberLabel.textColor = .label
        numberLabel.textAlignment = .left
        
        let textLabel = UILabel()
        textLabel.text = text
        textLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        textLabel.textColor = .label
        textLabel.textAlignment = .left
        
        let textStack = UIStackView(arrangedSubviews: [numberLabel, textLabel])
        textStack.axis = .vertical
        textStack.spacing = 7
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        textStack.isLayoutMarginsRelativeArrangement = true
        
        container.addSubview(cardView)
        cardView.addSubview(textStack)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: container.topAnchor, constant: 1),
            cardView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 1),
            cardView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -1),
            cardView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -1),
            
            textStack.topAnchor.constraint(equalTo: cardView.topAnchor),
            textStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            textStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            textStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor)
        ])
        
        return container
    }
    
    private func setupCards() {
        // Очищаем существующие элементы
        mainCardStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        gradientBorders.forEach { $0.removeFromSuperview() }
        gradientBorders.removeAll()
        
        let record = trackerRecordStore.fetchCompletedTrackers().count
        trackersCompletedCount = record
    
        
        let perfect = trackerRecordStore.perfectDaysCount()
        perfectDays = perfect
        
        let longest = trackerRecordStore.longestStreak()
        longestStreak = longest
        
        let average = trackerRecordStore.averageTrackersPerDay()
        averageTracker = average
        
        let cards: [Card] = [
            Card(number: trackersCompletedCount, text: "Трекеров завершено"),
            Card(number: perfectDays, text: "Идеальные дни"),
            Card(number: longestStreak, text: "Лучший период"),
            Card(number: averageTracker, text: "Среднее значение")
        ]
        
        for cardData in cards {
            // Создаем карточку
            let cardView = createCardStack(number: cardData.number, text: cardData.text)
            mainCardStack.addArrangedSubview(cardView)
            
            // Создаем градиентную рамку для этой карточки
            let gradientBorder = createGradientBorderView()
            view.insertSubview(gradientBorder, belowSubview: cardView)
            gradientBorders.append(gradientBorder)
            
            // Устанавливаем констрейнты для градиентной рамки
            NSLayoutConstraint.activate([
                gradientBorder.topAnchor.constraint(equalTo: cardView.topAnchor, constant: -1),
                gradientBorder.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: -1),
                gradientBorder.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: 1),
                gradientBorder.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 1)
            ])
        }
        
        // Обновляем градиенты после создания всех рамок
        updateAllGradientFrames()
    }
    
    private func createGradientBorderView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 17
        view.backgroundColor = .clear
        view.clipsToBounds = true
        return view
    }
    
    private func updateAllGradientFrames() {
        for gradientBorder in gradientBorders {
            updateGradientFrame(for: gradientBorder)
        }
    }
    
    private func updateGradientFrame(for gradientBorder: UIView) {
        // Удаляем старые градиентные слои
        gradientBorder.layer.sublayers?.removeAll()
        
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.redGradient.cgColor,
            UIColor.greenGradient.cgColor,
            UIColor.blueGradient.cgColor
        ]
        gradient.locations = [0, 0.5, 1.0]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.frame = gradientBorder.bounds
        gradient.cornerRadius = 17
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = 2
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.path = UIBezierPath(
            roundedRect: gradientBorder.bounds.insetBy(dx: 1, dy: 1),
            cornerRadius: 16
        ).cgPath
        
        gradient.mask = shapeLayer
        gradientBorder.layer.addSublayer(gradient)
    }
}
