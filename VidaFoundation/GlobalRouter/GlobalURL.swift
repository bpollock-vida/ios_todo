//
//  ModuleURL.swift
//
//  Created by Brice Pollock on 6/12/15.
//  Copyright (c) 2015 Brice Pollock. All rights reserved.
//

import Foundation

// When creating a new renderer, you have to create a case for it in the GlobalURL, and give it a string URL in the GLobalURL path.
// TODO: How do we group these by feature to avoid a 60 strings in a file (Alex: Deep Linking Proposal)
public enum GlobalURL: CustomStringConvertible {
    case tab
    case toDoList
    case settings
    case todoForm
//    case newFeature

    public func moduleURL() -> URL? {
        let URL = Foundation.URL(string: "pack-list-mobile://app")!
        return URL.appendingPathComponent(path)
    }

    public var description: String {
        return moduleURL()?.description ?? ""
    }
}

// MARK: Define URLs

// TODO: add documentation about path vs. routingPath
extension GlobalURL {
    public var path: String {
        switch self {
        case .tab: return "tab"
        case .toDoList: return "toDoList"
        case .settings: return "settings"
        case .todoForm: return "todoForm"
//        case .newFeature: return "newFeature"
        }
    }
}

// MARK: Routing

// BRICE: Documentation needed, don't know what routing path means
extension GlobalURL {
    public var routingPath: String {
        return path
    }
}
