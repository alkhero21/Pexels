//
//  PhootoCollectionViewCell.swift
//  Pexels
//
//  Created by Alibek Allamzharov on 07.09.2023.
//

import UIKit

class PhootoCollectionViewCell: UICollectionViewCell {
    
    static let identifier: String = "PhootoCollectionViewCell"
    var photo: Photo?

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        imageView.layer.cornerRadius = 10
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = UIImage(named: "image_placeholder")
    }

    
    func setup(photo: Photo) {
        
        self.photo = photo
        
        let mediumPhotoUrlString: String = photo.src.medium
        guard let mediumPhotoUrl = URL(string: mediumPhotoUrlString) else {
            print("Couldn't create URL with given mediumPhotoURLString: \(mediumPhotoUrlString)")
            return
        }
        
        self.activityIndicatorView.startAnimating()
        let dataTask =  URLSession.shared.dataTask(with: mediumPhotoUrl, completionHandler: imageLoadCompletionHandler(data:urlResponse:error:))
        dataTask.resume()
    }
    
    func imageLoadCompletionHandler(data: Data?, urlResponse: URLResponse?, error: Error?) {
        
        if urlsAreSame(responseUrl: urlResponse?.url?.absoluteString) {
            
            DispatchQueue.main.async {
                self.activityIndicatorView.stopAnimating()
            }
        }
        
        if let error = error {
            print("Error load image - \(error.localizedDescription)")
        }else if let data = data {
            
            guard urlsAreSame(responseUrl: urlResponse?.url?.absoluteString) else {
                return
            }
            
            DispatchQueue.main.async {
                self.imageView.image = UIImage(data: data)
            }
        }
        
    }
    
    func urlsAreSame(responseUrl: String?) -> Bool {
        
        guard let currentPhotoUrl = self.photo?.src.medium, let responseURL = responseUrl  else {
            print("Current photo url OR Response url absent")
            return false
        }
        guard currentPhotoUrl == responseURL else {
            print("ATTENTION! currnetPhotoURL and responseURL are different")
            return false
        }
        return true
    }
}
