//
//  CreateNewCategoryScreen.swift
//  Tracker
//
//  Created by Николай Замараев on 06.12.2025.
//

import UIKit

protocol CreateNewCategoryViewControllerProtocol: AnyObject {
    func didTapDoneButton(_ categoryName: String?, mode: CreateNewCategoryViewController.Mode)
}

final class CreateNewCategoryViewController: UIViewController {
    
    enum Mode {
        case create
        case edit(String)
    }
    
    private let mode: Mode
    
    init(mode: Mode) {
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    weak var delegate: CreateNewCategoryViewControllerProtocol?
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        switch mode {
        case .create:
            label.text = "Новая категория"
        case .edit:
            label.text = "Редактирование категории"
        }
        
        return label
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(traitCollection.userInterfaceStyle == .light ? .white : .ypBlackDay, for: .normal)
        button.layer.cornerRadius = 16
        button.backgroundColor = traitCollection.userInterfaceStyle == .light ? .white : .ypBlackDay
        
        button.addAction(UIAction { [weak self] _ in
            self?.didTapDoneButton()
        }, for: .touchUpInside)
        
        return button
    }()
    
    private lazy var categoryName: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название категории"
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = UIColor(resource: .ypBackground)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupUI()
        setupConstraints()
        updateCreateButtonEnable()
        configureForMode()
    }
    
    private func setupUI() {
        view.addSubview(nameLabel)
        view.addSubview(categoryName)
        view.addSubview(addCategoryButton)
        view.addSubview(clearButton)
    }
    
    private func configureForMode() {
        if case .edit(let oldTitle) = mode {
            categoryName.text = oldTitle
            textChanged()
            categoryName.becomeFirstResponder()
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -32),
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            categoryName.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 38),
            categoryName.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            categoryName.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            categoryName.heightAnchor.constraint(equalToConstant: 75),
            
            clearButton.centerYAnchor.constraint(equalTo: categoryName.centerYAnchor),
            clearButton.trailingAnchor.constraint(equalTo: categoryName.trailingAnchor, constant: -16),
            clearButton.widthAnchor.constraint(equalToConstant: 17),
            clearButton.heightAnchor.constraint(equalToConstant: 17),
            
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func textChanged() {
        updateCreateButtonEnable()
        updateClearButtonVisible()
    }
    
    private func updateCreateButtonEnable() {
        let isCategoryNameEmpty = categoryName.text?.isEmpty ?? true
        
        let buttonIsReadyToUse = !isCategoryNameEmpty
        
        let backgroundColor = traitCollection.userInterfaceStyle == .light ? .ypBlackDay : UIColor(resource: .ypLightGray)
        
        addCategoryButton.isEnabled = buttonIsReadyToUse
        addCategoryButton.backgroundColor = buttonIsReadyToUse ? backgroundColor : .ypGray
    }
    
    private func updateClearButtonVisible() {
        let hasText = !(categoryName.text?.isEmpty ?? true)
        clearButton.isHidden = !hasText
    }
    
    @objc private func clearText() {
        categoryName.text = ""
        textChanged()
        
        if !categoryName.isFirstResponder {
            categoryName.becomeFirstResponder()
        }
    }
    
    private func didTapDoneButton() {
        let newCategoryName = categoryName.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        guard !newCategoryName.isEmpty else {
            showAlert(
                title: "Ошибка",
                message: "Название категории не может быть пустым"
            )
            return
        }
        
        if case .edit(let oldTitle) = mode {
            if newCategoryName == oldTitle {
                dismiss(animated: true)
                return
            }
        }
        
        delegate?.didTapDoneButton(newCategoryName, mode: mode)
        dismiss(animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        
        present(alert, animated: true)
    }
}
