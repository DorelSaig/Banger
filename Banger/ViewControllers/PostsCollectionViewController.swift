//
//  postsCollectionViewController.swift
//  Banger
//
//  Created by Dorel Saig on 04/06/2022.
//

import UIKit
import Kingfisher
import MapKit
import FirebaseStorage
import FirebaseDatabase
import Lottie

final class PostsCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    let cellId = "postCell"
    
    var tabar: TabViewController!
    var dataManager:DataManager?
    var posts: [Post]!
    let rootRef = Database.database().reference()
    var first = true
    
    @IBOutlet weak var posts_collection: UICollectionView!

    override func viewDidLoad() {
        
        var mp = self.parent as? PostsController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        dataManager = appDelegate.data
        
        posts = []
        
        fetchData()
        
        self.posts_collection.register(UINib(nibName: "PostCell", bundle: nil), forCellWithReuseIdentifier: cellId)
        
    }

    func fetchData(){
        
        let ref = rootRef.child("Posts")
        let regionRef = rootRef.child("Regions")
        regionRef.child(dataManager!.currentRegion!.city).child("posts").observe(DataEventType.childAdded, with: {snapshot in
            if snapshot.exists(){
                //                print("\(snapshot.key)")
                //self.posts.removeAll()
                //                self.fetchData()
                self.dataManager!.getPostFromDB(ref: ref, post: snapshot.value as! String, delegate: self)
                print("somthing changed in region \(snapshot.value as! String)")
                
            }
        })
        
    }
    
    
    
    // MARK: - Collection View 📚
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = posts_collection.dequeueReusableCell(withReuseIdentifier: "postCell", for: indexPath) as! PostCell
        
        
        cell.configure(imgUrl: posts[indexPath.row].imageUrl ?? "https://cdn-icons.flaticon.com/png/512/2549/premium/2549859.png?token=exp=1653856114~hmac=72ea04d1898a25bdb1692899f4f0094d")
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let mp = parent as? Delegate_ItemSelected
        mp?.itemSelected(post: posts[indexPath.row])
        
        let cell = collectionView.cellForItem(at: indexPath) as! PostCell
        
        cell.selected()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let mp = parent as? Delegate_ItemSelected
        mp?.itemDeselected(post: posts[indexPath.row])
        
        let cell = collectionView.cellForItem(at: indexPath) as! PostCell
        
        cell.deselect()
    }
    
    // Configure Item Size In Collection View
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        
        let numberofItem: CGFloat = 2
        
        let collectionViewWidth = self.posts_collection.bounds.width
        
        let extraSpace = (numberofItem - 1) * flowLayout.minimumInteritemSpacing
        
        let inset = flowLayout.sectionInset.right + flowLayout.sectionInset.left
        
        let width = Int((collectionViewWidth - extraSpace - inset) / numberofItem)
        
        return CGSize(width: width, height: width)
    }
}

extension PostsCollectionViewController: Get_Data_Protocol, Delegate_PostRecieved {
    
    func postRecieved(post: Post) {
        self.posts.append(post)
        let mp = self.parent as? Delegate_PostAdded
        //        print("\(post.locationName) Recievied From DB---------")
        mp?.postAdded(post: post)
        self.posts_collection.reloadData()
    }
    
    func getData(data: DataManager) {
        self.dataManager = data
    }
    
}


// MARK: - Delegates Protocols 📚

protocol Delegate_ItemSelected {
    func itemSelected(post:Post)
    func itemDeselected(post:Post)
}

protocol Delegate_PostAdded {
    func postAdded(post:Post)
}

protocol Get_Data_Protocol {
    func getData(data:DataManager)
}
