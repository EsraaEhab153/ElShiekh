//
//  AuthEndpoints.swift
//  Authentication
//
//  Created by Nadin Ahmed on 18/07/2026.
//
import Foundation
import NetworkKit
import Alamofire

enum AuthEndpoints: APIEndpoint {

    case login(email: String, password: String)
    case register(
        username: String,
        firstName: String,
        lastName: String,
        email: String,
        password: String,
        confirmPassword: String,
        phoneNumber: String,
        gender: String
    )
    case refresh(refreshToken: String)
    case logout(refreshToken: String)
    case me(accessToken: String)
    case verifyOTP(otp: String, email: String)
    case verifyEmail(email: String)
    case changePassword(
        email: String,
        password: String,
        confirmPassword: String
    )
    case googleSignIn(idToken: String)

    var baseURL: BaseURLType { .almahir }

    var path: String {
        switch self {
        case .login:
            return "auth/sheikh/login"

        case .register:
            return "auth/sheikh/register"

        case .refresh:
            return "auth/sheikh/refresh"

        case .logout:
            return "auth/logout"

        case .me:
            return "auth/me"

        case .verifyOTP(let otp, let email):
            return "forgot-password/verify-otp/\(otp)/\(email)"

        case .verifyEmail(let email):
            return "forgot-password/verify-email/\(email)"

        case .changePassword(let email, _, _):
            return "forgot-password/change-password/\(email)"

        case .googleSignIn:
            return "auth/sheikh/google"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .me: return .get
        default: return .post
        }
    }

    var parameters: Parameters? {
        switch self {
        case .login(let email, let password):
            return [
                "email": email,
                "password": password,
            ]

        case .register(
            let username,
            let firstName,
            let lastName,
            let email,
            let password,
            let confirmPassword,
            let phoneNumber,
            let gender
        ):
            return [
                "username": username,
                "firstName": firstName,
                "lastName": lastName,
                "email": email,
                "password": password,
                "confirmPassword": confirmPassword,
                "phoneNumber": phoneNumber,
                "gender": gender,
            ]

        case .refresh(let refreshToken):
            return [
                "refreshToken": refreshToken
            ]

        case .changePassword(_, let password, let confirmPassword):
            return [
                "password": password,
                "confirm_password": confirmPassword,
            ]

        case .logout(let refreshToken):
            return [
                "refreshToken": refreshToken
            ]

        case .verifyOTP,
            .verifyEmail,
            .me:
            return nil

        case .googleSignIn(let idToken):
            return [
                "idToken": idToken
            ]
        }
    }

    var encoding: ParameterEncoding {
        switch self {
        case .me:
            return URLEncoding.default
        default:
            return JSONEncoding.default
        }
    }

    var multipartBody: MultipartBody? {
        switch self {
        case .register(
            let username,
            let firstName,
            let lastName,
            let email,
            let password,
            let confirmPassword,
            let phoneNumber,
            let gender
        ):
            let payload: [String: String] = [
                "username": username,
                "firstName": firstName,
                "lastName": lastName,
                "email": email,
                "password": password,
                "confirmPassword": confirmPassword,
                "phoneNumber": phoneNumber,
                "gender": gender,
            ]
            guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
                return nil
            }
            return MultipartBody(parts: [
                MultipartPart(name: "data", data: jsonData, mimeType: "application/json")
            ])

        default:
            return nil
        }
    }
}
