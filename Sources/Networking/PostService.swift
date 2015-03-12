//
//  PostService.swift
//  Ello
//
//  Created by Ryan Boyajian on 3/19/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

typealias PostSuccessCompletion = (post: Post) -> ()

struct PostService {

    static func loadPost(postParam: String, success: PostSuccessCompletion, failure: ElloFailureCompletion?) {
        let endpoint = ElloAPI.PostDetail(postParam: postParam)
        ElloProvider.sharedProvider.elloRequest(endpoint,
            method: .GET,
            parameters: endpoint.defaultParameters,
            mappingType: endpoint.mappingType,
            success: { (data, responseConfig) in
                if let post = data as? Post {
                    success(post: post)
                }
                else {
                    ElloProvider.unCastableJSONAble(failure)
                }
            },
            failure: failure
        )
    }
    
}