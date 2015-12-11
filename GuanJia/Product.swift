//
//  Product.swift
//  GuanJia
//
//  Created by Liang Sun on 12/11/15.
//  Copyright © 2015 Lyon Sun. All rights reserved.
//

// {
//      "id":"1",
//      "name":"Nutrilon \u725b\u680f\u5976\u7c892\u6bb5 800\u514b",
//      "description":"\u9002\u54086-12\u4e2a\u6708\u7684\u5a74\u513f",
//      "stock":"0",
//      "image_id":"1",
//      "date_added":"2015-11-29 07:46:16",
//      "date_updated":"2015-12-07 20:52:52"
// }

import Foundation
import Alamofire
import SwiftyJSON

enum ProductFields: String {
    case DateAdded = "date_added"
    case DateUpdated = "date_updated"
    case Description = "description"
    case ID = "id"
    case ImageID = "image_id"
    case Name = "name"
    case Stock = "stock"
}

let API_URL = "http://otrack.dev/api"

class ProductsWrapper {
    var products: Array<Product>?
}

class Product {
    
    // MARK: Properties
    var id: Int?
    var name: String?
    var description: String?
    var stock: Int?
    var image_id: Int?
    var date_added: String?
    var date_updated: String?
    
    // MARK: Initialization
    required init(json: SwiftyJSON.JSON) {
        self.id = json[ProductFields.ID.rawValue].int
        self.name = json[ProductFields.Name.rawValue].string
        self.description = json[ProductFields.Description.rawValue].string
        self.stock = json[ProductFields.Stock.rawValue].int
        self.image_id = json[ProductFields.ImageID.rawValue].int
        self.date_added = json[ProductFields.DateAdded.rawValue].string // TODO: parse to NSDate?
        self.date_updated = json[ProductFields.DateUpdated.rawValue].string // TODO: parse to NSDate?
    }
    
    // MARK: URLs
//    class func endpointForSingleProduct(id: Int) -> String {
//        return API_URL + "/products/\(id)"
//    }
    
    class func endpointForProducts() -> String {
        return API_URL + "/products"
    }
    
    // MARK: GET
    // Get one product
    
//    class func productByID(id: Int, completionHandler: (Result<Product, NSError>) -> Void) {
//        Alamofire.request(.GET, endpointForSingleProduct(id))
//            .responseObject { response in
//                completionHandler(response.result)
//        }
//    }
    
    private class func getProductsAtPath(path: String, completionHandler: (ProductsWrapper?, NSError?) -> Void) {
        Alamofire.request(.GET, path)
            .responseProductsArray { response in
                if let error = response.result.error
                {
                    completionHandler(nil, error)
                    return
                }
                completionHandler(response.result.value, nil)
        }
    }
    
    class func getProducts(completionHandler: (ProductsWrapper?, NSError?) -> Void) {
        getProductsAtPath(Product.endpointForProducts(), completionHandler: completionHandler)
    }
}

extension Alamofire.Request {    
    func responseProductsArray(completionHandler: Response<ProductsWrapper, NSError> -> Void) -> Self {
        let responseSerializer = ResponseSerializer<ProductsWrapper, NSError> { request, response, data, error in
            guard error == nil else {
                return .Failure(error!)
            }
            guard let responseData = data else {
                let failureReason = "Array could not be serialized because input data was nil."
                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                return .Failure(error)
            }
            
            let JSONResponseSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            let result = JSONResponseSerializer.serializeResponse(request, response, responseData, error)
            
            switch result {
            case .Success(let value):
                let results = SwiftyJSON.JSON(value)
                let productsWrapper = ProductsWrapper()
                
                var allProducts:Array = Array<Product>()
                
                for product in results
                {
                    let product = Product(json: product.1)
                    allProducts.append(product)
                }
                productsWrapper.products = allProducts
                return .Success(productsWrapper)
            case .Failure(let error):
                return .Failure(error)
            }
        }
        
        return response(responseSerializer: responseSerializer,
            completionHandler: completionHandler)
    }
}