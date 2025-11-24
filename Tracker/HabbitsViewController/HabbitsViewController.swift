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
        view.addSubview(trackerName)
        view.addSubview(tableView)
        view.addSubview(clearButton)
        view.addSubview(overSymbols)
        view.addSubview(cancelButton)
        view.addSubview(createButton)
        
        setupConstraints()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            newHabbitLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -32),
            newHabbitLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            trackerName.topAnchor.constraint(equalTo: newHabbitLabel.bottomAnchor, constant: 38),
            trackerName.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            trackerName.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            trackerName.heightAnchor.constraint(equalToConstant: 75),
            
            overSymbols.topAnchor.constraint(equalTo: trackerName.bottomAnchor, constant: 8),
            overSymbols.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            clearButton.centerYAnchor.constraint(equalTo: trackerName.centerYAnchor),
            clearButton.trailingAnchor.constraint(equalTo: trackerName.trailingAnchor, constant: -16),
            clearButton.widthAnchor.constraint(equalToConstant: 17),
            clearButton.heightAnchor.constraint(equalToConstant: 17),
            
            tableView.topAnchor.constraint(equalTo: trackerName.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 150),
            
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -4),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            createButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 4),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
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
        guard let trackerName = trackerName.text, !trackerName.isEmpty, let selectedCategory, !selectedCategory.isEmpty else { return }
        
        let newTracker = Tracker(id: UUID(),
                                 name: trackerName,
                                 color: .systemCyan,
                                 schedule: selectedSchedule,
                                 emoji: "💻")
        
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
