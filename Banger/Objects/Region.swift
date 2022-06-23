class Region {
    var uuid: String
    var country:String
    var city:String
    var imgUrl:String
    var posts:[String]
    
    
    init(uuid:String, city: String, country:String) {
        self.uuid = uuid
        self.city = city
        self.country = country
        self.imgUrl = "https://firebasestorage.googleapis.com/v0/b/superme-e69d5.appspot.com/o/images%2Fimg_profile_pic.JPG?alt=media&token=5970cec0-9663-4ddd-9395-ef2791ad938d"
        self.posts = ["dasdadaddaasd"]
    }
    
    
    
    
    
    
}
