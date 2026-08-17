import Foundation
import NetworkKit
import Alamofire

public enum ProfileEndpoints: APIEndpoint {
    case updateProfile(id: String, firstName: String, lastName: String, phoneNumber: String)
    
    public var baseURL: BaseURLType { .almahir }
    
    public var path: String {
        switch self {
        case .updateProfile(let id, _, _, _):
            return "sheikh/\(id)"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .updateProfile:
            return .put
        }
    }
    
    public var parameters: Parameters? {
        switch self {
        case .updateProfile(_, let firstName, let lastName, let phoneNumber):
            return [
                "firstName": firstName,
                "lastName": lastName,
                "phoneNumber": phoneNumber
            ]
        }
    }
    
    public var encoding: ParameterEncoding {
        return JSONEncoding.default
    }
    
    public var multipartBody: MultipartBody? {
        return nil
    }
}
