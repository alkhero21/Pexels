//
//  MainViewController.swift
//  Pexels
//
//  Created by Alibek Allamzharov on 02.09.2023.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchHistooryCollectionView: UICollectionView!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    var searchPhotosResponse: SearchPhotosResponse? {
        didSet {
            DispatchQueue.main.async {
                self.imageCollectionView.reloadData()
            }
        }
    }
    
    var photos: [Photo] {
        return searchPhotosResponse?.photos ?? []
    }
    
    let savedSearchTextArrayKey: String = "savedSearchTextArrayKey"
    var searchTextArray: [String] = [] {
        didSet{
            searchHistooryCollectionView.reloadData()
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.title = "Pexels"
        
        searchBar.delegate = self
        
        // Image CollectionView Setup
        imageCollectionView.layer.cornerRadius = 10
        imageCollectionView.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        imageCollectionView.register(UINib(nibName: PhootoCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: PhootoCollectionViewCell.identifier)
        imageCollectionView.dataSource = self
        
        imageCollectionView.delegate = self
        imageCollectionView.refreshControl = UIRefreshControl()
        imageCollectionView.refreshControl!.addTarget(self, action: #selector(search), for: .valueChanged)
        
        
        // Search History CollectionView Setup
        
        let flowLayout = searchHistooryCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        flowLayout?.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        searchHistooryCollectionView.register(UINib(nibName: SearchTextCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: SearchTextCollectionViewCell.identifier)
        searchHistooryCollectionView.dataSource = self
        searchHistooryCollectionView.delegate = self
        
        resetSearchTextArray()
        
        
    }
    @objc
    func search() {
        self.searchPhotosResponse = nil
        
        guard let searchText = searchBar.text else {
            print("Search bar text is nil")
            return
        }
        
        guard !searchText.isEmpty else {
            print("Search bar text is empty")
            return
        }
        
        
        // Save Searchign Text
        
        save(searchText: searchText)
        
        let endpoint: String = "https://api.pexels.com/v1/search"
        guard var urlComponents = URLComponents(string: endpoint) else {
            print("Couldn't create URLComponents instance from endpoint - \(endpoint)")
            return
        }
        
        let parameters = [
            URLQueryItem(name: "query", value: searchText),
            URLQueryItem(name: "per_page", value: "20")
        ]
        
        urlComponents.queryItems = parameters
        
        guard let url: URL = urlComponents.url else {
            print("URL is nil")
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        
        let APIKey: String = "1VICU1HooGGM3ZZKEryGCHhpmNN53yeqilpoexinoq54h1oK2qiLcndb"
        urlRequest.addValue(APIKey, forHTTPHeaderField: "Authorization")
        
        if imageCollectionView.refreshControl?.isRefreshing == false {
            imageCollectionView.refreshControl?.beginRefreshing()
        }
        
        let urlSession: URLSession = URLSession(configuration: .default)
        let dataTask: URLSessionDataTask = urlSession.dataTask(with: urlRequest, completionHandler: searchPhotosHandler(data:urlResponse:error:))
        
        dataTask.resume()
        
    }
    
    func searchPhotosHandler(data: Data?, urlResponse: URLResponse?, error: Error?) {
        
        print("Method searchPhotosHandler was called")
        
        DispatchQueue.main.async {
            if self.imageCollectionView.refreshControl?.isRefreshing == true {
                self.imageCollectionView.refreshControl?.endRefreshing()
            }
        }
        
        if let error = error {
            print("Search Photos endpoint error - \(error.localizedDescription)")
        }else if let data = data {
            
            do {
                
//                let jsonObject = try JSONSerialization.jsonObject(with: data)
//                print("Search Photos endpoint jsonObject - \(jsonObject)")
                
                let searchPhotosResponse = try JSONDecoder().decode(SearchPhotosResponse.self, from: data)
                print("Search Photos endpoint searchPhotosResponse - \(searchPhotosResponse)")
                
                
                self.searchPhotosResponse = searchPhotosResponse
                
            }catch let error {
                print("Search Photos endpoint serialization error - \(error.localizedDescription)")
            }
        }
        
        if let urlResponse = urlResponse, let httpResponse = urlResponse as? HTTPURLResponse {
            print("Search Photos enpoint http response url status - \(httpResponse.statusCode)")
        }
    }
    
    func save(searchText: String) {
        var existingArray: [String] = getSaveSearchTextArray()
        existingArray.append(searchText)
        
        UserDefaults.standard.set(existingArray, forKey: savedSearchTextArrayKey)
        
        resetSearchTextArray()
    }
    
    func getSaveSearchTextArray() -> [String] {
        
        let array: [String] = UserDefaults.standard.stringArray(forKey: savedSearchTextArrayKey) ?? []
        return array
    }
    
    func getSortedSearchTextArray() -> [String] {
        let savedSearchTextArray: [String] = getSaveSearchTextArray()
        let reversedSaveSearchTextArray: [String] = savedSearchTextArray.reversed()
        return reversedSaveSearchTextArray
    }
    
    func resetSearchTextArray() {
        self.searchTextArray = getUniqueSearchTextArray()
    }
    
    func getUniqueSearchTextArray() -> [String] {
        
        let sortedSearchTextArray : [String] = getSortedSearchTextArray()
        
        var sortedSearchTextArrayWithUniqueValues: [String] = []
        
        sortedSearchTextArray.forEach { searchText in
            
            if !sortedSearchTextArrayWithUniqueValues.contains(searchText){
                sortedSearchTextArrayWithUniqueValues.append(searchText)
            }
        }
        return sortedSearchTextArrayWithUniqueValues
    }
    
    func deleteContact(at index: Int) {
        searchTextArray.remove(at: index)
        UserDefaults.standard.set(searchTextArray, forKey: savedSearchTextArrayKey)
    }

}

extension MainViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        search()
    }
    
}


extension MainViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch collectionView {
        case imageCollectionView:
            return photos.count
            
        case searchHistooryCollectionView:
            return searchTextArray.count
            
        default:
            return 0
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        switch collectionView{
            
        case imageCollectionView:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhootoCollectionViewCell.identifier, for: indexPath) as! PhootoCollectionViewCell
            cell.setup(photo: self.photos[indexPath.item])
            return cell
            
        case searchHistooryCollectionView:
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchTextCollectionViewCell.identifier, for: indexPath) as! SearchTextCollectionViewCell
            let title = searchTextArray[indexPath.item]
            cell.set(title: title)
            cell.deleteButtonWasTapped = {
                self.deleteContact(at: indexPath.item)
            }
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
}


extension MainViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let flowLayout: UICollectionViewFlowLayout? = collectionViewLayout as? UICollectionViewFlowLayout
        let horizontalSpacing: CGFloat = ( flowLayout?.minimumInteritemSpacing ?? 0 ) + collectionView.contentInset.left + collectionView.contentInset.right
        let width: CGFloat = ( collectionView.frame.width - horizontalSpacing ) / 2
        let height: CGFloat = width + (width / 2)
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch collectionView {
            
        case imageCollectionView:
            
            let photo = self.photos[indexPath.item]
            let url = photo.src.large2X
            
            let vc = ImageScrollViewController(imageURL: url)
            self.navigationController?.pushViewController(vc, animated: true)
            
        case searchHistooryCollectionView:
            
            let searchText: String = searchTextArray[indexPath.item]
            searchBar.text = searchText
            search()
            
        default:
            ()
            
        }
    
    }
}


