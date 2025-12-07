//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Николай Замараев on 04.12.2025.
//

import UIKit

struct OnboardingPage {
    var title: String
    var image: UIImage
}

final class OnboardingViewControllers: UIPageViewController {
    
    let firstPage = OnboardingPage(title: "Отслеживайте только то, что хотите",
                                   image: UIImage(resource: .backFirst))
    
    let secondPage = OnboardingPage(title: "Даже если это не литры воды и йога",
                                    image: UIImage(resource: .backSecond))
    
    private lazy var pages: [UIViewController] = {
        let firstVC = createViewControllers(firstPage)
        let secondVC = createViewControllers(secondPage)
        return [firstVC, secondVC]
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .systemGray2
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.isUserInteractionEnabled = false
        return pageControl
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton()
        button.setTitle("Вот это технологии!", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypBlackDay
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addAction(UIAction { [weak self] _ in
            self?.openMainScreen()
        }, for: .touchUpInside)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }
        
        
        view.addSubview(pageControl)
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -134),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            button.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createViewControllers(_ page: OnboardingPage) -> UIViewController {
        let vc = UIViewController()

            let backImage = UIImageView()
            backImage.image = page.image
            backImage.translatesAutoresizingMaskIntoConstraints = false

            let label = UILabel()
            label.text = page.title
            label.textColor = .ypBlackDay
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = .systemFont(ofSize: 32, weight: .bold)
            label.textAlignment = .center
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping

            vc.view.addSubview(backImage)
            vc.view.addSubview(label)

            NSLayoutConstraint.activate([
                backImage.topAnchor.constraint(equalTo: vc.view.topAnchor),
                backImage.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor),
                backImage.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor),
                backImage.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor),

                label.leadingAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                label.trailingAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
                label.bottomAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.bottomAnchor, constant: -270)
            ])

            return vc
    }
    
    private func openMainScreen() {
        let trackerViewController = TrackerViewController()
        let navigationController = UINavigationController(rootViewController: trackerViewController)
        navigationController.modalPresentationStyle = .fullScreen
        AppSettings.isFirstAppOpen = false
        present(navigationController, animated: true)
    }
}

extension OnboardingViewControllers: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil}
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else { return nil}
        
        guard pages.indices.contains(previousIndex) else { return nil}
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil}
        
        let previousIndex = viewControllerIndex + 1
        
        guard previousIndex >= 0 else { return nil}
        
        guard pages.indices.contains(previousIndex) else { return nil}
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}



