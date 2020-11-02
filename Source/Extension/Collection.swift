//
//  Collection.swift
//  RBC
//
//  Created by Dmitry Smirnov on 10.07.2020.
//  Copyright © 2020 MobileUp. All rights reserved.
//

import UIKit

// MARK: - Collection

public extension Collection {

    subscript (safe index: Index) -> Element? {

        return indices.contains(index) ? self[index] : nil
    }
}
