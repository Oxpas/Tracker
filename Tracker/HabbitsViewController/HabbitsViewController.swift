//
//  HabbitsViewController.swift
//  Tracker
//
//  Created by Николай Замараев on 26.10.2025.
//
import UIKit

protocol CreateTrackerViewControllerDelegate: AnyObject {
    func didCreateNewTracker(_ tracker: Tracker, titleCategory: String)
}

final class HabbitsViewController: UIViewController {
    
    weak var delegate: CreateTrackerViewControllerDelegate?
    
    private var selectedEmojiIndex: Int?
    private var selectedColorIndex: Int?
    
    private let emojies = [
        "🙂" ,"😻" ,"🌺" ,"🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝", "😪"
    ]
    
    private let colors: [UIColor] = [
        UIColor(resource: .beigeCell),
        UIColor(resource: .blueCell),
        UIColor(resource: .darkPurpleCell),
        UIColor(resource: .deepOrangeCell),
        UIColor(resource: .deepPinkCell),
        UIColor(resource: .deepPurpleCell),
        UIColor(resource: .greenCell),
        UIColor(resource: .lightBeigeCell),
        UIColor(resource: .lightBlueCell),
        UIColor(resource: .lightGreenCell),
        UIColor(resource: .lightPinkCell),
        UIColor(resource: .lightPurpleCell),
        UIColor(resource: .orangeCell),
        UIColor(resource: .pinkCell),
        UIColor(resource: .purpleCell),
        UIColor(resource: .ultraGreenCell),
        UIColor(resource: .ultraPinkCell),
        UIColor(resource: .redCell)
    ]
    
    private let cellData = [
        "Категория",
        "Расписание"
    ]
    
    private var selectedCategory: String?
    private var selectedSchedule: [Weekdays] = []
    
    private lazy var newHabbitLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Новая привычка"
        
        return label
    }()
    
    private lazy var trackerName: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = UIColor(named: "YP Background")
        textField.layer.cornerRadius = 16
        
        let leftPadding = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = leftPadding
        textField.leftViewMode = .always
        
        textField.addAction(UIAction { [weak self] _ in
            self?.textChanged()
        }, for: .editingChanged)
        
        return textField
    }()
    
    private lazy var clearButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = UIColor(named: "YP Gray")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        
        button.addAction(UIAction { [weak self] _ in
            self?.clearText()
        }, for: .touchUpInside)
        
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.layer.cornerRadius = 16
        tableView.isScrollEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.ypRed, for: .normal)
        
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addAction(UIAction { [weak self] _ in
            self?.dismiss(animated: true)
        }, for: .touchUpInside)
        
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.setTitle("Создать", for: .normal)
        button.backgroundColor = .ypGray
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addAction(UIAction { [weak self] _ in
            self?.createTracker()
        }, for: .touchUpInside)
        
        return button
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Emoji"
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.itemSize = CGSize(width: 52, height: 52)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: "EmojiCell")
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.isScrollEnabled = false
        
        
        return collectionView
    }()
    
    private lazy var colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.itemSize = CGSize(width: 52, height: 52)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: "ColorCell")
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.isScrollEnabled = false
        
        return collectionView
    }()
    
    private lazy var colorLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Цвет"
        label.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    
    
    private lazy var overSymbols: UILabel = {
        let label = UILabel()
        
        label.text = "Ограничение 38 символов"
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = .ypRed
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.alpha = 0
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        
        setupUI()
        updateCreateButtonEnable()
    }
    
    func setupUI() {
        view.addSubview(newHabbitLabel)
        view.addSubview(cancelButton)
        view.addSubview(createButton)
        view.addSubview(scrollView)
        
        scrollView.addSubview(trackerName)
        scrollView.addSubview(tableView)
        scrollView.addSubview(clearButton)
        scrollView.addSubview(overSymbols)
        scrollView.addSubview(emojiLabel)
        scrollView.addSubview(emojiCollectionView)
        scrollView.addSubview(colorLabel)
        scrollView.addSubview(colorCollectionView)
        
        setupConstraints()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: newHabbitLabel.bottomAnchor, constant: 1),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -16),
            
            newHabbitLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -32),
            newHabbitLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            trackerName.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 24),
            trackerName.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            trackerName.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            trackerName.heightAnchor.constraint(equalToConstant: 75),
            
            clearButton.centerYAnchor.constraint(equalTo: trackerName.centerYAnchor),
            clearButton.trailingAnchor.constraint(equalTo: trackerName.trailingAnchor, constant: -16),
            clearButton.widthAnchor.constraint(equalToConstant: 17),
            clearButton.heightAnchor.constraint(equalToConstant: 17),
            
            overSymbols.topAnchor.constraint(equalTo: trackerName.bottomAnchor, constant: 8),
            overSymbols.centerXAnchor.constraint(equalTo: scrollView.frameLayoutGuide.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: overSymbols.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 150),
            
            emojiLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            emojiLabel.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 28),
            emojiLabel.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -28),
            
            emojiCollectionView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 16),
            emojiCollectionView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 18),
            emojiCollectionView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -18),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 204),
            
            colorLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            colorLabel.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 28),
            colorLabel.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -28),
            
            colorCollectionView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 16),
            colorCollectionView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 18),
            colorCollectionView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -18),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 204),
            colorCollectionView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -20),
            
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -4),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            createButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 4),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        
    }
    
    @objc private func textChanged() {
        updateClearButtonVisible()
        overTextLength()
        updateCreateButtonEnable()
    }
    
    @objc private func clearText() {
        trackerName.text = ""
        textChanged()
        
        if trackerName.isFirstResponder {
            
        } else {
            trackerName.becomeFirstResponder()
        }
    }
    
    func updateClearButtonVisible() {
        let hasText = !(trackerName.text?.isEmpty ?? true)
        clearButton.isHidden = !hasText
    }
    
    func formatScheduleText(_ schedule: [Weekdays]) -> String {
        if schedule.count == Weekdays.allCases.count {
            return "Каждый день"
        } else {
            let sortedSchedule = schedule.sorted { $0.rawValue < $1.rawValue }
            return sortedSchedule.map { $0.shortName }.joined(separator: ", ")
        }
    }
    
    private func overTextLength() {
        guard let text = trackerName.text else { return }
        
        if text.count >= 38 {
            let index = text.index(text.startIndex, offsetBy: 38)
            trackerName.text = String(text[..<index])
            
            UIView.animate(withDuration: 0.2) {
                self.overSymbols.alpha = 1
            }
        } else {
            UIView.animate(withDuration: 0.3) {
                self.overSymbols.alpha = 0
            }
        }
    }
    
    private func createTracker() {
        guard let trackerName = trackerName.text,
              !trackerName.isEmpty,
              let selectedCategory,
              !selectedCategory.isEmpty,
              let emojiIndex = selectedEmojiIndex,
              let colorIndex = selectedColorIndex
        else { return }
        
        let emoji = emojies[emojiIndex]
        let color = colors[colorIndex]
        
        let newTracker = Tracker(id: UUID(),
                                 name: trackerName,
                                 color: color,
                                 schedule: selectedSchedule,
                                 emoji: emoji)
        
        delegate?.didCreateNewTracker(newTracker, titleCategory: selectedCategory)
        dismiss(animated: true)
    }
    
    private func updateCreateButtonEnable() {
        let isTrackerNameEmpty = trackerName.text?.isEmpty ?? true
        let isSomeCategorySelected = selectedCategory != nil
        let isSomeScheduleSelected = !selectedSchedule.isEmpty
        
        let buttonIsReadyToUse = !isTrackerNameEmpty && isSomeCategorySelected && isSomeScheduleSelected
        
        createButton.isEnabled = buttonIsReadyToUse
        createButton.backgroundColor = buttonIsReadyToUse ? .black : .ypGray
    }
}

extension HabbitsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cellData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        
        cell.textLabel?.text = cellData[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
        cell.textLabel?.textColor = UIColor(named: "YP BlackDay")
        cell.backgroundColor = UIColor(named: "YP Background")
        
        if indexPath.row == 1, !selectedSchedule.isEmpty {
            let scheduleText = formatScheduleText(selectedSchedule)
            cell.detailTextLabel?.text = scheduleText
            cell.detailTextLabel?.textColor = .gray
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 17)
        }
        
        if indexPath.row == 0, let category = selectedCategory {
            cell.detailTextLabel?.text = category
            cell.detailTextLabel?.textColor = .gray
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 17)
        }
        
        if indexPath.row == 0 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: .greatestFiniteMagnitude)
        }
        
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            print("Selected kategory cell")
            let categoryViewController = CategoryViewController()
            
            categoryViewController.delegate = self
            let navigationController = UINavigationController(rootViewController: categoryViewController)
            present(navigationController, animated: true)
            
        case 1:
            print("Selected schedule cell")
            let scheduleViewController = ScheduleViewController()
            scheduleViewController.selectedDays = selectedSchedule
            
            scheduleViewController.delegate = self
            let navigationController = UINavigationController(rootViewController: scheduleViewController)
            present(navigationController, animated: true)
        default:
            break
        }
    }
}

extension HabbitsViewController: ScheduleSelectionDelegate {
    func didSelecteWeekdays(_ schedule: [Weekdays]) {
        selectedSchedule = schedule
        tableView.reloadData()
        updateCreateButtonEnable()
    }
}

extension HabbitsViewController: CategorySelectionDelegate {
    func didCategorySelect(_ category: String) {
        selectedCategory = category
        tableView.reloadData()
        updateCreateButtonEnable()
    }
}

extension HabbitsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == emojiCollectionView {
            return emojies.count
        } else {
            return colors.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as? EmojiCell
            cell?.emojiLabel.text = emojies[indexPath.item]
            cell?.setSelected(selectedEmojiIndex == indexPath.row)
            guard let cell else { return cell ?? UICollectionViewCell() }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCell", for: indexPath) as? ColorCell
            let color = colors[indexPath.item]
            cell?.configure(with: color)
            cell?.setSelected(selectedColorIndex == indexPath.item, with: color)
            guard let cell else { return cell ?? UICollectionViewCell()}
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            selectedEmojiIndex = indexPath.item
            collectionView.reloadData()
            print("Selected emoji: \(emojies[indexPath.item])")
        } else {
            selectedColorIndex = indexPath.item
            collectionView.reloadData()
            print("Selected color: \(colors[indexPath.item])")
        }
    }
    
}
