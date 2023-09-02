//
//  OnboardingViewController.swift
//  Pexels
//
//  Created by Alibek Allamzharov on 28.08.2023.
//

import UIKit

class OnboardingViewController: UIViewController {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    
    static let KEY: String = "UserDidSeeOnboarding"
    
    var pages: [OnboardingModel] = [] {
        didSet {
            
            pageControl.currentPage = pages.count
            collectionView.reloadData()
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(UINib(nibName: OnboardingCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: OnboardingCollectionViewCell.identifier)
        collectionView.dataSource = self
        
        collectionView.delegate = self
        
        generatePages()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        skipButton.layer.cornerRadius = skipButton.frame.height / 2
        nextButton.layer.cornerRadius = nextButton.frame.height / 2
    }

    
    func generatePages() {
        pages = [
            OnboardingModel(imageName: "onboarding1", title: "Grow effortlessly", subtitle: "Lorem Ipsum is simply dummy text of the printing and typesetting industry."),
            OnboardingModel(imageName: "onboarding2", title: "Save automatically", subtitle: "Lorem Ipsum is simply dummy text of the printing and typesetting industry."),
            OnboardingModel(imageName: "onboarding3", title: "Smart, Fun and Rewarding", subtitle: "Lorem Ipsum is simply dummy text of the printing and typesetting industry.")
        ]
    }

    
    @IBAction func skipButtonClicked(_ sender: UIButton) {
        start()
    }
    
    @IBAction func nextButtonCllicked(_ sender: UIButton) {
        
        
        if pageControl.currentPage == pageControl.numberOfPages - 1 {
            start()
        }else {
            pageControl.currentPage += 1
            collectionView.scrollToItem(at: IndexPath(item: pageControl.currentPage, section: 0), at: .centeredHorizontally, animated: true)
            
            
            hundlePageChanges()
        }
    }
    
    func start() {
        //function a
        
        UserDefaults.standard.set(true, forKey: OnboardingViewController.KEY)
        
        let mainVC = MainViewController()
        view.window?.rootViewController = mainVC
        view.window?.makeKeyAndVisible()
    }
    
    func hundlePageChanges() {
        if pageControl.currentPage == pageControl.numberOfPages - 1 {
            
            skipButton.isHidden = true
            nextButton.setTitle("Начать", for: .normal)
        }else {
            skipButton.isHidden = false
            nextButton.setTitle("Дальше", for: .normal)
        }
    }
    
}

extension OnboardingViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingCollectionViewCell.identifier, for: indexPath) as! OnboardingCollectionViewCell
        
        let onboardingModel = pages[indexPath.item]
        cell.setup(onboardingModel: onboardingModel)
        
        return cell
    }
}

extension OnboardingViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
}

extension OnboardingViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewDidEndDecelerating at offset x: \(scrollView.contentOffset.x)")
        
        pageControl.currentPage = Int( scrollView.contentOffset.x / scrollView.frame.width )
        hundlePageChanges()
        
    }
    
    
}
