//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Николай Замараев on 28.10.2025.
//
import UIKit

protocol ScheduleSelectionDelegate: AnyObject {
    func didSelecteWeekdays(_ schedule: [Weekdays])
}

final class ScheduleViewController: UIViewController {
    
    weak var delegate: ScheduleSelectionDelegate?
    var selectedDays: [Weekdays] = []
    
    lazy private var scheduleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Расписание"
        
        return label
    }()
    
    lazy private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "weekdaysCell")
        tableView.layer.cornerRadius = 16
        tableView.isScrollEnabled = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor(named: "YP BlackDay")
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addAction(UIAction { [weak self] _ in
            self?.doneButtonTapped()
        }, for: .touchUpInside)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupUI()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupUI() {
        view.addSubview(scheduleLabel)
        view.addSubview(tableView)
        view.addSubview(doneButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scheduleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -32),
            scheduleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scheduleLabel.heightAnchor.constraint(equalToConstant: 22),
            
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 525),
        ])
    }
    
    private func doneButtonTapped() {
        delegate?.didSelecteWeekdays(selectedDays)
        dismiss(animated: true)
    }
}

extension ScheduleViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Weekdays.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "weekdaysCell", for: indexPath)
        let weekdays = Weekdays.allCases[indexPath.row]
        
        cell.textLabel?.text = weekdays.namesOfWeekdays
        cell.textLabel?.textAlignment = .left
        cell.backgroundColor = UIColor(named: "YP Background")
        
        let switchButton = UISwitch()
        switchButton.isOn = selectedDays.contains(weekdays)
        
        switchButton.addAction(UIAction { [weak self] _ in
            if switchButton.isOn {
                if !(self?.selectedDays.contains(weekdays) ?? false) {
                    self?.selectedDays.append(weekdays)
                }
            } else {
                self?.selectedDays.removeAll()
            }
        }, for: .valueChanged)
        
        
        cell.accessoryView = switchButton
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
