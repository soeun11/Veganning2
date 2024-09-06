//
//  VeganningApp.swift
//  Veganning
//
//  Created by 김민솔 on 8/2/24.
//

import SwiftUI

@main
struct VeganningApp: App {
    var recipeData = RecipeData()

    var body: some Scene {
        WindowGroup {
            TabbedView()
                .environmentObject(recipeData) 
        }
    }
}
