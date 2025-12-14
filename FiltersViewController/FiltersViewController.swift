//
//  FiltersViewController.swift
//  Tracker
//
//  Created by Николай Замараев on 13.12.2025.
//

import UIKit

protocol FiltersViewControllerDelegate: AnyObject {
    func didFilterSelect(_ filter: Filters)
}

final class FiltersViewController: UIViewController {
    
    weak var delegate: FiltersViewControllerDelegate?
    private var selectedFilterIndex: Int? = nil
    
    private lazy var filtersLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Фильтры"
        
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "filterCell")
        tableView.layer.cornerRadius = 16
        tableView.isScrollEnabled = true
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.clipsToBounds = true
        
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        tableView.delegate = self
        tableView.dataSource = self
        
        setupUI()
        
    }
    
    private func setupUI() {
        view.addSubview(filtersLabel)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate ([
            filtersLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -32),
            filtersLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 525)
        ])
    }
    
    
}

extension FiltersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let numberOfRows = tableView.numberOfRows(inSection: indexPath.section)
        
        if indexPath.row == numberOfRows - 1 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.layer.masksToBounds = true
        } else {
            cell.layer.cornerRadius = 0
            cell.layer.masksToBounds = false
        }
    }
}

extension FiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Filters.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "filterCell", for: indexPath)
        
        let filter = Filters.allCases[indexPath.row]
        cell.textLabel?.text = filter.rawValue
        cell.backgroundColor = UIColor(named: "YP Background")
    
        if indexPath.row == 0 || indexPath.row == 1 {
            cell.accessoryView = nil
            return cell
        }
        
        let checkmarkImageView: UIImageView
        if let existingView = cell.accessoryView as? UIImageView {
            checkmarkImageView = existingView
        } else {
            checkmarkImageView = UIImageView(image: UIImage(systemName: "checkmark"))
            checkmarkImageView.tintColor = .ypBlue
            checkmarkImageView.contentMode = .scaleAspectFit
            cell.accessoryView = checkmarkImageView
        }
        
        checkmarkImageView.isHidden = indexPath.row != selectedFilterIndex
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        selectedFilterIndex = indexPath.row
        let selectedFilter = Filters.allCases[indexPath.row]
        delegate?.didFilterSelect(selectedFilter)
        
        tableView.reloadData()
        
        dismiss(animated: true)
    }
}
