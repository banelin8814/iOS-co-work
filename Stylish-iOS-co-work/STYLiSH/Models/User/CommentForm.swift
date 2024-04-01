//
//  CommentForm.swift
//  STYLiSH
//
//  Created by Kyle Lu on 2024/4/1.
//  Copyright © 2024 AppWorks School. All rights reserved.
//

import Foundation
struct CommentForm: Decodable {
    let userId: Int64
    let productId: Int64
    let rate: Int
    let comment: String
}
