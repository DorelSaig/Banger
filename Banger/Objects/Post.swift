//
//  Post.swift
//  Banger
//
//  Created by Dorel Saig on 31/05/2022.
//

import MapKit
import IGListKit

class Post: NSObject, MKAnnotation {
    let uuid:String?
    let title:String?
    let imageUrl:String?
    let creatorUuid:String?
    let locationName:String? // Will Be Creator Name Instead
    let coordinate: CLLocationCoordinate2D
    let note: String?
    
    
    init(uuid: String?, title: String?, imageUrl:String?, creator:String?, creatorUuid:String?, coordinate:CLLocationCoordinate2D, note: String?){
        self.uuid = uuid
        self.title = title
        self.imageUrl = imageUrl
        self.creatorUuid = creatorUuid
        self.locationName = creator
        self.coordinate = coordinate
        self.note = note
        
        super.init()
    }
    
    var subtitle: String? {
        return locationName
    }
}

extension Post: ListDiffable{
    func diffIdentifier() -> NSObjectProtocol {
        return uuid! as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? Post else {
            return false
        }
        
        return self.uuid == object.uuid

    }
    
    
}
