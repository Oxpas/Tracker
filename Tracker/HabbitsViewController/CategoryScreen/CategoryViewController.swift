import UIKit

protocol CategorySelectionDelegate: AnyObject {
    func didCategorySelect(_ category: String)
}

final class CategoryViewController: UIViewController {
    
    weak var delegate: CategorySelectionDelegate?
    private var viewModel: CategoryViewModel!
    
    var initiallySelectedCategory: String?
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        
        tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: CategoryTableViewCell.identifier)
        tableView.layer.cornerRadius = 16
        tableView.translatesAutoresizingMaskIntoConstraints = false

        return tableView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Категория"
        
        return label
    }()
    
    private lazy var imagePlaceholder: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(resource: .placeholder)
        image.translatesAutoresizingMaskIntoConstraints = false
        
        return image
    }()
    
    private lazy var textPlaceholder: UILabel = {
        let label = UILabel()
        label.text = "Привычки и события можно объединить по смыслу"
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
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Добавить категорию", for: .normal)
        button.layer.cornerRadius = 16
        button.backgroundColor = traitCollection.userInterfaceStyle == .light ? .ypBlackDay : .white
        button.setTitleColor(traitCollection.userInterfaceStyle == . light ? .white : .black, for: .normal)
        
        button.addTarget(self, action: #selector(buttonAddCategoryTapped), for: .touchUpInside)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupBindings()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.setInitiallySelectedCategory(initiallySelectedCategory)
        viewModel.loadCategories()
    }
    
    func configure(trackerCategoryStore: TrackerCategoryStore) {
        self.viewModel = CategoryViewModel(trackerCategoryStore: trackerCategoryStore)
    }
    
    private func setupBindings() {
        guard viewModel != nil else { return }
        
        viewModel.onCategoriesUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.updatePlaceholderVisibility()
            }
        }
        
        viewModel.onErrorOccurred = { [weak self] errorMessage in
            DispatchQueue.main.async {
                self?.showErrorAlert(message: errorMessage)
            }
        }
        
        viewModel.onCategorySelected = { [weak self] category in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self?.delegate?.didCategorySelect(category)
                self?.dismiss(animated: true)
            }
        }
    }
    
    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(nameLabel)
        view.addSubview(placeholderView)
        view.addSubview(addCategoryButton)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        setupConstraints()
        updatePlaceholderVisibility()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -16),
            
            nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -32),
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nameLabel.heightAnchor.constraint(equalToConstant: 22),
            
            placeholderView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            placeholderView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            placeholderView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -232),
            
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func updatePlaceholderVisibility() {
        placeholderView.isHidden = viewModel?.hasCategories ?? false
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func buttonAddCategoryTapped() {
        let createNewCategoryViewController = CreateNewCategoryViewController()
        createNewCategoryViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: createNewCategoryViewController)
        present(navigationController, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getNumberOfCategories()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryTableViewCell.identifier,
            for: indexPath
        ) as? CategoryTableViewCell else {
            return UITableViewCell()
        }
        
        if let categoryTitle = viewModel.getCategoryTitle(at: indexPath.row) {
            cell.configure(with: categoryTitle)
            cell.setSelected(viewModel.isCategorySelected(at: indexPath.row))
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.selectCategory(at: indexPath.row)
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

// MARK: - CreateNewCategoryViewControllerProtocol
extension CategoryViewController: CreateNewCategoryViewControllerProtocol {
    func didTapDoneButton(_ categoryName: String?) {
        guard let categoryName = categoryName, !categoryName.isEmpty else { return }
        viewModel.createCategory(with: categoryName)
    }
}
