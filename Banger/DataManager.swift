import Foundation
import UIKit
import MapKit
import FirebaseStorage
import FirebaseDatabase

class DataManager {
    var currentUserUID: String?
    var currentUser: User?
    var currentRegion: Region?
    var currentPost: Post?
    var currentSavedPost: Post?
    var test: String?
    let storage = Storage.storage()
    var storageRef: StorageReference!
    var ref: DatabaseReference!
    
    var exist:Int?
    
    func setCurrentUserUID(uid:String){
         
            self.currentUserUID = uid
        
    }
    
    func setCurrentUser(user:User){
        self.currentUser = user
    }
    
    func setCurrentRegion(region:Region){
        self.currentRegion = region
    }
    
    func setCurrentPost(post:Post){
        self.currentPost = post
    }
    
    func setCurrentSavedPost(post:Post){
        self.currentSavedPost = post
    }
    
    func setTestString(t:String){
        self.test = t
    }
    
    func setRegionExist(b:Int){
        self.exist = b
    }
    
    
    // -------------------------------------------------------------------------------------------------------------------------------------
    
    func userSnapToUser(uuid:String, userSnap:Dictionary<String, AnyObject>) -> User{
        let user = User(uuid: uuid, name: userSnap["name"] as! String, instaUrl: userSnap["instaUrl"] as! String)
        user.imgUrl = userSnap["imageUrl"] as! String
        let arr = userSnap["savedPost"] as! NSArray
        user.savedPost = arr.compactMap({ $0 as? String })
        
        return user
    }
    
    func userToDict(user:User) ->  [String : Any]{
        let userInfoDictionary = ["uuid": user.uuid,
                                  "name" : user.name,
                                  "imageUrl": user.imgUrl,
                                  "instaUrl" : user.instaUrl,
                                  "savedPost" : user.savedPost] as [String : Any]
        return userInfoDictionary
    }
    
    func regionToDict(region:Region) -> [String:Any]{
        let regionInfoDictionary = ["city": region.city,
                                    "country": region.country,
                                    "imageUrl": region.imgUrl,
                                    "posts" : region.posts as NSArray] as [String : Any]
        return regionInfoDictionary
    }
    
    func postToDict(post:Post) -> [String:Any]{
        let postInfoDictionary = ["title": post.title! as String,
                                  "imageUrl": post.imageUrl! as String,
                                  "creatorUuid":post.creatorUuid! as String,
                                  "locationName": post.locationName! as String,
                                  "latitude": post.coordinate.latitude,
                                  "longitude": post.coordinate.longitude,
                                  "note": post.note! as String] as [String : Any]
        return postInfoDictionary
    }
    

    func goToInsta(instaUrl:String){
        guard let instagram = URL(string: instaUrl) else { return }
        UIApplication.shared.open(instagram)
    }
    
    
}

extension DataManager {
    
    func uploadImagePic(img1 :UIImage, uuid:String, file:String, delegate: Delegate_Image_Uploaded){
            var data = NSData()
        data = img1.jpegData(compressionQuality: 0.8)! as NSData
            // set upload path
        let filePath = "\(uuid )" // path where you wanted to store img in storage
        let metaData = StorageMetadata()
            metaData.contentType = "image/jpg"

            self.storageRef = storage.reference()
        let userref = self.storageRef.child(file).child(filePath)
        let uploadTask = userref.putData(data as Data, metadata: metaData){(metaData,error) in
                if let error = error {
                            print(error.localizedDescription)

                            return
                        }
        }
        
        uploadTask.observe(.success) { snapshot in
            userref.downloadURL(completion: {(url:URL?, error:Error?) in
                
                delegate.imageUploaded(imageUrl: url!.absoluteString)
                
            })
        }
 
            
        
        }
    
    func addPostToDB(post:Post, delegate:Delegate_Stored_In_DB){
        ref = Database.database().reference()
        let postInfoDictionary = postToDict(post: post)
        
        self.ref.child("Posts").child(post.uuid!).setValue(postInfoDictionary, withCompletionBlock: {err, ref in
            if let error = err {
                print("postInfoDictionary was not Saved: \(error.localizedDescription)")
            } else {
                print("postInfoDictionary saved successfully!")
                self.updateRegionPostsList(post: post, delegate: delegate)
                
            }
        })
    }
    
    
    func addRegionToDB(region:Region, delegate: Delegate_Stored_In_DB){
        
        //-------- Store user in DB
        ref = Database.database().reference()
        let regionInfoDictionary = regionToDict(region: region)
        
        
        self.ref.child("Regions").child(region.city).setValue(regionInfoDictionary, withCompletionBlock: { err, ref in
            if let error = err {
                print("regionInfoDictionary was not saved: \(error.localizedDescription)")
            } else {
                print("regionInfoDictionary saved successfully!")
                delegate.storedSuccessfuly()
                
            }
        }
        )
        
        
    }
    
    func addUserToDB(user:User){
        //-------- Store user in DB
        ref = Database.database().reference()
        let userInfoDictionary = userToDict(user: user)
        
        self.ref.child("users").child("\(currentUserUID ?? "error")").setValue(userInfoDictionary, withCompletionBlock: { err, ref in
                    if let error = err {
                        print("userInfoDictionary was not saved: \(error.localizedDescription)")
                    } else {
                        print("userInfoDictionary saved successfully!")
                        self.setCurrentUser(user: user)
                    }
                }
            )
    }
    
    func getPostFromDB(ref:DatabaseReference, post:String, delegate:Delegate_PostRecieved){
        var p:Post!
        ref.child(post).observe(.value, with: { snapshot in
            if snapshot.exists() {
                guard let eachPostDict = snapshot.value as? Dictionary<String, AnyObject> else {return}
                let cll = CLLocationCoordinate2D(latitude: eachPostDict["latitude"] as! CLLocationDegrees, longitude: eachPostDict["longitude"] as! CLLocationDegrees)
                p = Post(uuid: snapshot.key, title: eachPostDict["title"] as? String, imageUrl: eachPostDict["imageUrl"] as? String, creator: eachPostDict["locationName"] as? String, creatorUuid: eachPostDict["creatorUuid"] as? String, coordinate: cll, note: eachPostDict["note"] as? String)
                
                delegate.postRecieved(post: p)
            };
        })
    }
    
    func checkIfRegionExist(city:String, delegate: Delegate_Region_Exist){
        
        ref = Database.database().reference()
        ref.child("Regions").getData(completion: { error, snapshot in
            
//            print(city)
            delegate.regionExist(bool: (snapshot?.hasChild(city))!)
           
        })
    }
    
    func updateRegionPostsList(post:Post, delegate:Delegate_Stored_In_DB){
        
        currentRegion?.posts.append(post.uuid!)
        
        ref = Database.database().reference()
        ref.child("Regions").child(currentRegion!.city).updateChildValues(["posts":currentRegion?.posts as Any], withCompletionBlock: {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
              print("Data could not be update: \(error).")
            } else {
              print("Data Updated successfully!")
                delegate.storedSuccessfuly()
            }
          })
    }
    
    
    func updateUserSavedPosts(postUuid:String, add:Bool, delegate:Delegate_Stored_In_DB){
        
        if add {
            self.currentUser?.savedPost.append(postUuid)
        } else {
            if let index = self.currentUser?.savedPost.firstIndex(of: postUuid) {
                self.currentUser?.savedPost.remove(at: index)
            }
        }
        
        ref = Database.database().reference()
        ref.child("users").child(currentUserUID!).updateChildValues(["savedPost":currentUser?.savedPost as Any], withCompletionBlock: {
            (error:Error?, ref:DatabaseReference) in
        if let error = error {
            print("Data could not be update: \(error).")
        } else {
            print("Data Updated successfully!!!!!")
            delegate.storedSuccessfuly()
        }
        })
    }
    
    func updateUserDetails(user:User){
        
        addUserToDB(user: user)

    }
    
    
    
}

extension DataManager {
    func displayMyAlertMessage(message:String, delegate:Delegate_Alert){
        let myAlert = UIAlertController(title: "WOF", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        myAlert.addAction(okAction)
        delegate.showAlert(myAlert: myAlert)
        
    }
}

protocol Delegate_Alert {
    func showAlert(myAlert:UIAlertController)
}

protocol Delegate_Image_Uploaded {
    func imageUploaded(imageUrl:String?)
}

protocol Delegate_Stored_In_DB {
    func storedSuccessfuly()
}

protocol Delegate_Region_Exist {
    func regionExist(bool:Bool)
}

protocol Delegate_PostRecieved {
    func postRecieved(post:Post)
}
