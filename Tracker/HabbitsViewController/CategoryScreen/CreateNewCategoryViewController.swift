//
//  CreateNewCategoryScreen.swift
//  Tracker
//
//  Created by Николай Замараев on 06.12.2025.
//

import UIKit

protocol CreateNewCategoryViewControllerProtocol: AnyObject {
    func didTapDoneButton(_ categoryName: String?)
}

final class CreateNewCategoryViewController: UIViewController {
    
    weak var delegate: CreateNewCategoryViewControllerProtocol?
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Новая категория"
        
        return label
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Готово", for: .normal)
        button.layer.cornerRadius = 16
        button.backgroundColor = UIColor(resource: .ypBlackDay)
        
        button.addAction(UIAction { [weak self] _ in
            self?.didTapDoneButton()
        }, for: .touchUpInside)
        
        return button
    }()
    
    private lazy var categoryName: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название категории"
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupUI()
        setupConstraints()
        updateCreateButtonEnable()
    }
    
    private func setupUI() {
        view.addSubview(nameLabel)
        view.addSubview(categoryName)
        view.addSubview(addCategoryButton)
        view.addSubview(clearButton)
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
        
        addCategoryButton.isEnabled = buttonIsReadyToUse
        addCategoryButton.backgroundColor = buttonIsReadyToUse ? .black : .ypGray
    }
    
    private func updateClearButtonVisible() {
        let hasText = !(categoryName.text?.isEmpty ?? true)
        clearButton.isHidden = !hasText
    }
    
    @objc private func clearText() {
        categoryName.text = ""
        textChanged()
        
        if categoryName.isFirstResponder {
            
        } else {
            categoryName.becomeFirstResponder()
        }
    }
    
    private func didTapDoneButton() {
        delegate?.didTapDoneButton(categoryName.text ?? nil)
        dismiss(animated: true)
    }
}
