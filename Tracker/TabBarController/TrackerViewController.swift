//
//  FirstViewController.swift
//  Tracker
//
//  Created by Николай Замараев on 24.10.2025.
//

import Foundation
import UIKit

class TrackerViewController: UIViewController {
    
    private var categories: [TrackerCategory] = []
    private var completedTrackers: Set<TrackerRecord> = []
    private var visibleCategories: [TrackerCategory] = []
    private let calendar = Calendar.current
    var currentDate: Date {
        return datePicker.date
    }
    
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.tintColor = UIColor(named: "YP Black")
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.locale = Locale(identifier: "ru_RU")
        picker.backgroundColor = .clear
        
        picker.addAction(UIAction { [weak self] _ in
            self?.datePickerValueChanged()
        }, for: .valueChanged)
        
        return picker
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.font = UIFont.boldSystemFont(ofSize: 34)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let search: UISearchBar = {
        let search = UISearchBar()
        search.placeholder = "Поиск"
        search.searchBarStyle = .minimal
        search.translatesAutoresizingMaskIntoConstraints = false
        search.layer.cornerRadius = 8
        search.clipsToBounds = true
        
        let searchField = search.searchTextField
        searchField.backgroundColor = UIColor(named: "YP LigthGay")
        
        return search
    }()
    
    private lazy var imagePlaceholder: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "Placeholder")
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let textUnderPicturePlaceholder: UILabel = {
        let text = UILabel()
        text.text = "Что будем отслеживать?"
        text.translatesAutoresizingMaskIntoConstraints = false
        text.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        text.textAlignment = .center
        text.textColor = UIColor(named: "YP BlackDay")
        return text
    }()
    
    private lazy var placeholderView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imagePlaceholder, textUnderPicturePlaceholder])
        
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: "TrackerCell")
        collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderView")
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        placeholderVisible()
        createMockData()
        reloadData()
        
        
        search.delegate = self
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(placeholderView)
        view.addSubview(search)
        view.addSubview(datePicker)
        view.addSubview(titleLabel)
        view.addSubview(collectionView)
        
        setupConstraints()
    }
    
    private func placeholderVisible() {
        let hasVisibleTrackers = visibleCategories.contains { !$0.trackers.isEmpty }
        placeholderView.isHidden = hasVisibleTrackers
        collectionView.isHidden = !hasVisibleTrackers
    }
    
    private func setupNavigationBar() {
        let addButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addTrackerButtonTapped))
        
        addButton.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        addButton.tintColor = UIColor(named: "YP BlackDay")
        
        let customDatePicker = UIBarButtonItem(customView: datePicker)
        
        navigationItem.leftBarButtonItem = addButton
        navigationItem.rightBarButtonItem = customDatePicker
        navigationItem.leftBarButtonItem?.imageInsets = UIEdgeInsets.zero
        navigationItem.leftBarButtonItem?.setBackButtonBackgroundVerticalPositionAdjustment(0, for: .default)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1),
            
            search.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 7),
            search.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            search.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            search.heightAnchor.constraint(equalToConstant: 36),
            
            imagePlaceholder.widthAnchor.constraint(equalToConstant: 80),
            imagePlaceholder.heightAnchor.constraint(equalToConstant: 80),
            
            placeholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            
            collectionView.topAnchor.constraint(equalTo: search.bottomAnchor, constant: 24),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func reloadData() {
        let selectedDate = datePicker.date
        let weekdaysFilter = Calendar.current.component(.weekday, from: selectedDate)
        
        visibleCategories = categories.map { category in
            let filteredTrackers = category.trackers.filter { tracker in
                tracker.schedule.contains { weekday in
                    weekday.number == weekdaysFilter
                }
            }
            return TrackerCategory(title: category.title, trackers: filteredTrackers)
        }.filter { !$0.trackers.isEmpty }
        
        
        
        collectionView.reloadData()
        placeholderVisible()
    }
    
    private func isTrackerCompletedToday(_ trackerID: UUID) -> Bool {
        let calendar = Calendar.current
        let selectedDate = datePicker.date
        let normalizedSelectedDate = calendar.startOfDay(for: selectedDate)
        return completedTrackers.contains { record in
            record.trackerID == trackerID && calendar.isDate(record.date, inSameDayAs: normalizedSelectedDate)}
    }
    
    private func uncompleteTracker(_ trackerID: UUID) {
        let calendar = Calendar.current
        let selectedDate = datePicker.date
        let normalizedSelectedDate = calendar.startOfDay(for: selectedDate)
        
        if let record = completedTrackers.first(where: {
            $0.trackerID == trackerID && calendar.isDate($0.date, inSameDayAs: normalizedSelectedDate)
        }) {
            completedTrackers.remove(record)
            
            if let indexPath = findIndexPathForTracker(with: trackerID) {
                collectionView.reloadItems(at: [indexPath])
            }
        }
    }
    
    private func completeTracker(_ trackerID: UUID) {
        let calendar = Calendar.current
        let selectedDate = datePicker.date
        let today = Date()
        
        let normalizedSelectedDate = calendar.startOfDay(for: selectedDate)
        let normalizedDay = calendar.startOfDay(for: today)
        
        guard normalizedSelectedDate <= normalizedDay else { return }
        
        let newRecord = TrackerRecord(trackerID: trackerID, date: normalizedSelectedDate)
        completedTrackers.insert(newRecord)
        
        if let indexPath = findIndexPathForTracker(with: trackerID) {
            collectionView.reloadItems(at: [indexPath])
        }
    }
    
    private func findIndexPathForTracker(with id: UUID) -> IndexPath? {
        for (sectionIndex, category) in visibleCategories.enumerated() {
            for (itemIndex, tracker) in category.trackers.enumerated() {
                if tracker.id == id {
                    return IndexPath(item: itemIndex, section: sectionIndex)
                }
            }
        }
        return nil
    }
    
    @objc func datePickerValueChanged() {
        updateCompleteButtonsState()
        reloadData()
    }
    
    private func updateCompleteButtonsState() {
        for case let cell as TrackerCell in collectionView.visibleCells {
            guard let indexPath = collectionView.indexPath(for: cell) else { continue }
            let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
            let isCompletedToday = isTrackerCompletedToday(tracker.id)
            
            cell.updateCompleteButton(isCompletedToday: isCompletedToday, color: tracker.color)
        }
    }
    
    @objc func addTrackerButtonTapped() {
        let habbitsViewController = HabbitsViewController()
        let navigationController = UINavigationController(rootViewController: habbitsViewController)
        present(navigationController, animated: true)
    }
    
    func createMockData() {
        let mockTrackers = [
            Tracker(id: UUID(), name: "Пить воду", color: .systemBlue, schedule: [.monday, .tuesday, .wednesday, .friday, .saturday, .sunday], emoji: "💧"),
            Tracker(id: UUID(), name: "Бег", color: .systemGreen, schedule: [.monday, .wednesday, .friday], emoji: "🏃"),
            Tracker(id: UUID(), name: "Чтение", color: .systemOrange, schedule: [.tuesday, .saturday], emoji: "📚")
        ]
        
        categories = [TrackerCategory(title: "Здоровье", trackers: mockTrackers)]
        reloadData()
        placeholderVisible()
    }
}

extension TrackerViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        
        reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}


extension TrackerViewController: CreateTrackerViewControllerDelegate {
    func didCreateNewTracker(_ tracker: Tracker, titleCategory: String) {
        var newCategories = categories
        
        if let index = newCategories.firstIndex(where: { $0.title == titleCategory }) {
            var updatedTrackers = newCategories[index].trackers
            updatedTrackers.append(tracker)
            newCategories[index] = TrackerCategory(title: titleCategory, trackers: updatedTrackers)
        } else {
            
            let newCategory = TrackerCategory(title: titleCategory, trackers: [tracker])
            newCategories.append(newCategory)
        }
        categories = newCategories
        reloadData()
        
        dismiss(animated: true)
    }
}

extension TrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let availableWidth = collectionView.frame.width - 9
        let cellWidth = availableWidth / 2
        
        return CGSize(width: cellWidth, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 46)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
    }
}

//TODO: - Доделать отображение таблицы
extension TrackerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard section < visibleCategories.count else { return 0}
        return visibleCategories[section].trackers.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }
        
        guard indexPath.section < visibleCategories.count,
              indexPath.item < visibleCategories[indexPath.section].trackers.count else {
            return cell
        }
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        let completedDays = completedTrackers.filter { $0.trackerID == tracker.id }.count
        
        print("🔄 Configuring cell - completedDays: \(completedDays) for tracker: \(tracker.id)")
        
        let isCompletedToday = isTrackerCompletedToday(tracker.id)
        
        cell.configure(
            with: tracker,
            completedDays: completedDays,
            isCompletedToday: isCompletedToday
        )
        
        cell.doneButtonTapped = { [weak self] in
            guard let self = self else { return }
            let isCurrentlyCompleted = self.isTrackerCompletedToday(tracker.id)
            if isCurrentlyCompleted {
                self.uncompleteTracker(tracker.id)
            } else {
                self.completeTracker(tracker.id)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderView", for: indexPath) as? HeaderView else {
            return UICollectionReusableView()
        }
        
        guard indexPath.section < visibleCategories.count else {
            return header
        }
        
        header.configure(with: visibleCategories[indexPath.section].title)
        return header
    }
}


