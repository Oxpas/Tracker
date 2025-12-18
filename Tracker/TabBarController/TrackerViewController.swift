//
//  FirstViewController.swift
//  Tracker
//
//  Created by Николай Замараев on 24.10.2025.
//
import UIKit

final class TrackerViewController: UIViewController {
    
    var trackerStore: TrackerStore?
    var trackerRecordStore: TrackerRecordStore?
    var analyticsService: AnalyticsService?
    
    private var categories: [TrackerCategory] = []
    private var completedTrackers: Set<TrackerRecord> = []
    private var visibleCategories: [TrackerCategory] = []
    private let calendar = Calendar.current
    var currentDate: Date {
        return datePicker.date
    }
    
    private var currentFilter: Filters = .allTrackers {
        didSet {
            UserDefaults.standard.set(currentFilter.rawValue, forKey: "selectedFilter")
            reloadData()
        }
    }
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.tintColor = traitCollection.userInterfaceStyle == .light ? .ypBlackDay : .white
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.translatesAutoresizingMaskIntoConstraints = false
        
        let currentLanguage = Bundle.main.preferredLocalizations.first ?? "en"
        let localeId = currentLanguage == "ru" ? "ru_RU" : "en_US"
        picker.locale = Locale(identifier: localeId)
        picker.backgroundColor = .systemBackground
        
        picker.addAction(UIAction { [weak self] _ in
            self?.datePickerValueChanged()
        }, for: .valueChanged)
        
        return picker
        
        

    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("trackers_label", comment: "TrackerViewController")
        label.font = UIFont.boldSystemFont(ofSize: 34)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let search: UISearchBar = {
        let search = UISearchBar()
        search.placeholder = NSLocalizedString("search_field", comment: "TrackerViewController")
        search.searchBarStyle = .minimal
        search.translatesAutoresizingMaskIntoConstraints = false
        search.layer.cornerRadius = 8
        search.clipsToBounds = true
        
        let searchField = search.searchTextField
        
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
        text.text = NSLocalizedString("text_placeholer", comment: "TrackerViewController")
        text.translatesAutoresizingMaskIntoConstraints = false
        text.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        text.textAlignment = .center
        text.textColor = UIColor.label
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
        collectionView.alwaysBounceVertical = true
        
        return collectionView
    }()
    
    private lazy var filterButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        button.setTitle(NSLocalizedString("filter_button", comment: "TrackerViewController"), for: .normal)
        button.backgroundColor = UIColor(resource: .redCell)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.isHidden = false
        
        button.addAction(UIAction { [weak self] _ in
            self?.filterButtonTapped()
        }, for: .touchUpInside)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
        
        trackerStore?.delegate = self
        
        let params: [String: Any] = [
            "event" : "open",
            "screen" : "Main"
        ]
        analyticsService?.report(event: "open", params: params)
        
        if trackerStore == nil {
            let dataService = DataService.shared
            trackerStore = dataService.trackerStore
            trackerRecordStore = dataService.trackerRecordStore
            trackerStore?.delegate = self
        }
        
        if let savedFilterRaw = UserDefaults.standard.string(forKey: "selectedFilter"),
           let savedFilter = Filters(rawValue: savedFilterRaw) {
            currentFilter = savedFilter
        } else {
            currentFilter = .allTrackers
            UserDefaults.standard.set(currentFilter.rawValue, forKey: "selectedFilter")
        }
        
        loadData()
        reloadData()
        
        placeholderVisible()
        
        
        search.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        let params: [String : Any] = [
            "event" : "close",
            "screen" : "Main"
        ]
        
        analyticsService?.report(event: "close", params: params)
    }
    
    
    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        
        view.addSubview(placeholderView)
        view.addSubview(search)
        view.addSubview(datePicker)
        view.addSubview(titleLabel)
        view.addSubview(collectionView)
        view.addSubview(filterButton)
        
        setupConstraints()
    }
    
    private func placeholderVisible() {
        let hasVisibleTrackers = visibleCategories.contains { !$0.trackers.isEmpty }
        
        if hasVisibleTrackers {
            placeholderView.isHidden = true
            collectionView.isHidden = false
        } else {
            if currentFilter != .allTrackers && currentFilter != .todayTrackers {
                imagePlaceholder.image = UIImage(resource: .filterPlaceholder)
                textUnderPicturePlaceholder.text = NSLocalizedString("found_nothing", comment: "TrackerViewController")
            } else {
                imagePlaceholder.image = UIImage(resource: .placeholder)
                textUnderPicturePlaceholder.text = NSLocalizedString("text_placeholer", comment: "TrackerViewController")
            }
            placeholderView.isHidden = false
            collectionView.isHidden = true
        }
    }
    
    private func updateFilterButtonVisibility() {
            guard let trackerStore = trackerStore else { return }
            let allTrackersForDate = trackerStore.fetchTrackers(for: currentDate)
            let hasAnyTrackersForDate = allTrackersForDate.contains { !$0.trackers.isEmpty }
            
            if !hasAnyTrackersForDate {
                filterButton.isHidden = true
                return
            }
            
            let scrollView = collectionView
            let contentHeight = scrollView.contentSize.height
            let frameHeight = scrollView.frame.height
            let contentOffsetY = scrollView.contentOffset.y
            
            let isScrolledToBottom = contentOffsetY + frameHeight >= contentHeight - 20
            
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.filterButton.isHidden = isScrolledToBottom
            }
    }
    
    private func setupNavigationBar() {
        let addButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addTrackerButtonTapped))
        
        addButton.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        addButton.tintColor = .label
        
        
        let customDatePicker = UIBarButtonItem(customView: datePicker)
        customDatePicker.tintColor = .label
        
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
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            filterButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 130),
            filterButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -130),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    private func loadData() {
        guard let trackerRecordStore = trackerRecordStore else {return}
        completedTrackers = trackerRecordStore.fetchCompletedTrackers()
    }
    
    @objc private func reloadData() {
        
        guard let trackerStore = trackerStore else {
            return
        }
        
        if currentFilter == .todayTrackers {
            let today = Date()
            if !calendar.isDate(datePicker.date, inSameDayAs: today) {
                datePicker.date = today
            }
        }
        
        let selectedDate = datePicker.date
        var filteredCategories = trackerStore.fetchTrackers(for: selectedDate)
        
        visibleCategories = trackerStore.fetchTrackers(for: selectedDate)
        print("📊 Найдено категорий: \(visibleCategories.count)")
        print("📊 Всего трекеров: \(visibleCategories.reduce(0) { $0 + $1.trackers.count })")
        
        loadData()
        
        switch currentFilter {
        case .allTrackers:
            break
        case .todayTrackers:
            let today = Date()
            if !calendar.isDate(selectedDate, inSameDayAs: today) {
                datePicker.date = today
                
                DispatchQueue.main.async { [weak self] in
                    self?.reloadData()
                }
                return
            }
        case .completedTrackers:
            filterCompletedTrackers(from: &filteredCategories)
            
        case .uncompletedTrackers:
            filterNotCompletedTrackers(from: &filteredCategories)
            
        }
        
        visibleCategories = filteredCategories.filter { !$0.trackers.isEmpty }
        
        collectionView.reloadData()
        placeholderVisible()
        
        
        DispatchQueue.main.async { [weak self] in
            self?.updateFilterButtonVisibility()
        }
        
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
        
        guard let trackerRecordStore = trackerRecordStore else { return }
        
        do {
            try trackerRecordStore.removeRecord(for: trackerID, date: normalizedSelectedDate)
            completedTrackers = trackerRecordStore.fetchCompletedTrackers()
            
            if let indexPath = findIndexPathForTracker(with: trackerID) {
                collectionView.reloadItems(at: [indexPath])
            }
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func filterCompletedTrackers(from categories: inout [TrackerCategory]) {
        for i in 0..<categories.count {
            categories[i].trackers = categories[i].trackers.filter { tracker in
                isTrackerCompletedToday(tracker.id)
            }
        }
        visibleCategories = categories.filter { !$0.trackers.isEmpty }
    }
    
    private func filterNotCompletedTrackers(from categories: inout [TrackerCategory]) {
        for i in 0..<categories.count {
            categories[i].trackers = categories[i].trackers.filter { tracker in
                !isTrackerCompletedToday(tracker.id)
            }
        }
        visibleCategories = categories.filter { !$0.trackers.isEmpty }
    }
    
    private func completeTracker(_ trackerID: UUID) {
        let calendar = Calendar.current
        let selectedDate = datePicker.date
        let today = Date()
        
        let normalizedSelectedDate = calendar.startOfDay(for: selectedDate)
        let normalizedDay = calendar.startOfDay(for: today)
        
        guard normalizedSelectedDate <= normalizedDay,
              let trackerRecordStore = trackerRecordStore else { return }
        
        do {
            try trackerRecordStore.addRecord(for: trackerID, date: normalizedSelectedDate)
            completedTrackers = trackerRecordStore.fetchCompletedTrackers()
            
            if let indexPath = findIndexPathForTracker(with: trackerID) {
                collectionView.reloadItems(at: [indexPath])
            }
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
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
        let habitsViewController = HabitsViewController(mode: .create)
        habitsViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: habitsViewController)
        present(navigationController, animated: true)
        
        let params: [String: Any] = [
            "event" : "click",
            "screen" : "Main",
            "item" : "add_track"
        ]
        analyticsService?.report(event: "click", params: params)
    }
    
    private func filterButtonTapped() {
        let filtersVC = FiltersViewController()
        filtersVC.delegate = self
        
        let navigationVC = UINavigationController(rootViewController: filtersVC)
        navigationVC.modalPresentationStyle = .pageSheet
        
        if let sheet = navigationVC.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        
        present(navigationVC, animated: true)
        
        let params: [String: Any] = [
            "event": "click",
            "screen": "Main",
            "item": "filter"
        ]
        analyticsService?.report(event: "click", params: params)
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
    func didEditTracker(_ tracker: Tracker, titleCategory: String) {
        do {
            try trackerStore?.updateTracker(tracker, categoryTitle: titleCategory)
        } catch {
            print("Ошибка обновления трекера: \(error)")
        }
    }
    
    
    func didCreateNewTracker(_ tracker: Tracker, titleCategory: String) {
        do {
            try trackerStore?.createTracker(tracker, categoryTitle: titleCategory)
        } catch {
            print("Ошибка сохранения трекера: \(error)")
        }
        
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
                
                let params: [String : Any] = [
                    "event" : "click",
                    "screen" : "Main",
                    "item" : "track"
                ]
                analyticsService?.report(event: "click", params: params)
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

extension TrackerViewController: TrackerStoreDelegate {
    func didUpdateTrackers() {
        reloadData()
    }
}

extension TrackerViewController: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        
        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil
        ) { _ in
            
            let edit = UIAction(
                title: "Редактировать"
            ) { [weak self] _ in
                self?.editItem(at: indexPath)
            }
            
            let delete = UIAction(
                title: "Удалить",
                attributes: .destructive
            ) { [weak self] _ in
                self?.deleteItem(at: indexPath)
            }
            
            return UIMenu(title: "", children: [edit, delete])
        }
    }
    
    private func editItem(at indexPath: IndexPath) {
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        let categoryTitle = visibleCategories[indexPath.section].title
        
        let editVC = HabitsViewController(mode: .edit(tracker))
        editVC.selectedCategory = categoryTitle
        editVC.delegate = self
        
        let nav = UINavigationController(rootViewController: editVC)
        present(nav, animated: true)
        
        let params: [String: Any] = [
            "event": "click",
            "screen": "Main",
            "item": "edit"
        ]
        analyticsService?.report(event: "click", params: params)
    }
    
    private func deleteItem(at indexPath: IndexPath) {
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        
        let alert = UIAlertController(title: "Удалить трекер?",
                                      message: "Это действие нельзя будет отменить",
                                      preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "Отмена",
                                   style: .cancel,
                                   handler: nil)
        
        let delete = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            do {
                try self?.trackerStore?.deleteTrackers(tracker)
            } catch {
                print("Failed to delete tracker: \(error)")
            }
        }
        
        let params: [String: Any] = [
            "event": "click",
            "screen": "Main",
            "item": "delete"
        ]
        self.analyticsService?.report(event: "click", params: params)
        
        alert.addAction(cancel)
        alert.addAction(delete)
        
        collectionView.reloadData()
        present(alert, animated: true)
    }
}

extension TrackerViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateFilterButtonVisibility()
    }
}

extension TrackerViewController: FiltersViewControllerDelegate {
    func didFilterSelect(_ filter: Filters) {
        currentFilter = filter
        if filter == .todayTrackers {
            datePicker.date = Date()
        }
        reloadData()
    }
}
