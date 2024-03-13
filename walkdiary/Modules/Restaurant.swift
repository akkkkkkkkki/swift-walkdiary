import Foundation

class Restaurant {
    let name: String
    let address: String
    let opening: String
    let price: Float
    let rating: Float
    let url: String
    let commentNumber: Int
    let favoriteNumber: Int
    let distance: Int
    let coordinate: CLLocationCoordinate2D
    
    init(name: String, address: String, opening: String, price: Float, rating: Float, url: String, cn: Int, fn: Int, distance: Int, coordinate: CLLocationCoordinate2D) {
        self.name = name
        self.address = address
        self.opening = opening
        self.price = price
        self.rating = rating
        self.url = url
        self.commentNumber = cn
        self.favoriteNumber = fn
        self.distance = distance
        self.coordinate = coordinate
    }
    
    init(info: BMKPoiInfo, detail: BMKPOIDetailInfo) {
        name = info.name
        address = info.address ?? "未知"
        opening = detail.openingHours ?? "未知"
        price = Float(detail.price ) ?? 0.0
        rating = Float(detail.overallRating) ?? 0.0
        url = detail.detailURL
        commentNumber = detail.commentNumber ?? 0
        favoriteNumber = detail.favoriteNumber ?? 0
        distance = detail.distance ?? 0
        coordinate = info.pt
    }
}
