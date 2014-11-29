//
//  Authorization.swift
//  QuadratTouch
//
//  Created by Constantine Fry on 08/11/14.
//  Copyright (c) 2014 Constantine Fry. All rights reserved.
//

import Foundation
import UIKit

extension Session {
    
    public func canUseNativeOAuth() -> Bool {
        let baseURL = self.configuration.server.nativeOauthBaseURL
        let URL = NSURL(string: baseURL) as NSURL!
        return UIApplication.sharedApplication().canOpenURL(URL)
    }
    
    public func handleURL(URL: NSURL) -> Bool {
        if let nativeAuthorizer = self.authorizer as? NativeTouchAuthorizer {
            nativeAuthorizer.handleURL(URL) as Bool!
        }
        let nativeAuthorizer = NativeTouchAuthorizer(configuration: self.configuration)
        return nativeAuthorizer.handleURL(URL) as Bool!
    }
    
    public func authorizeWithViewController(viewController: UIViewController, completionHandler: AuthorizationHandler) {
        if (self.authorizer != nil) {
            fatalError("You are currently authorizing.")
            return
        }
        
        let block = { (accessToken, error) -> Void in
            if error != nil {
                self.processError(error!)
            }
            self.authorizer = nil
            completionHandler(accessToken != nil, error)
        } as (String?, NSError?) -> Void
        
        if (self.canUseNativeOAuth()) {
            let nativeAuthorizer = NativeTouchAuthorizer(configuration: self.configuration)
            nativeAuthorizer.authorize(block)
            self.authorizer = nativeAuthorizer
        } else {
            let touchAuthorizer = TouchAuthorizer(configuration: self.configuration)
            touchAuthorizer.authorize(viewController, completionHandler: block)
            self.authorizer = touchAuthorizer
        }
    }
}
