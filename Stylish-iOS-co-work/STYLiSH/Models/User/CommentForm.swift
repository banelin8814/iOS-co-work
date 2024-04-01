//
//  CommentForm.swift
//  STYLiSH
//
//  Created by Kyle Lu on 2024/4/1.
//  Copyright © 2024 AppWorks School. All rights reserved.
//

import Foundation

struct CommentsResponse: Decodable {
    let data: [CommentForm]
}

struct CommentForm: Decodable {
    let id: Int64?
    let name: String
    let rate: Int
    let comment: String
}
