class User {
    var uuid:String
    var name:String
    var imgUrl:String
    var instaUrl:String
    var savedPost:[String]
    
    
    init(uuid: String, name: String, instaUrl: String) {
        self.uuid = uuid
        self.name = name
        self.imgUrl = "https://firebasestorage.googleapis.com/v0/b/superme-e69d5.appspot.com/o/images%2Fimg_profile_pic.JPG?alt=media&token=5970cec0-9663-4ddd-9395-ef2791ad938d"
        self.instaUrl = instaUrl
        self.savedPost = ["init"]
    }
    
    
    
    
}
