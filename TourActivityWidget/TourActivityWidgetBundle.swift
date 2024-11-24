//
//  TourActivityWidgetBundle.swift
//  TourActivityWidget
//
//  Created by João Franco on 24/11/2024.
//  Copyright © 2024 com.miguel. All rights reserved.
//

import WidgetKit
import SwiftUI

@main
struct TourActivityWidgetBundle: WidgetBundle {
    var body: some Widget {
        TourActivityWidget()
        TourActivityWidgetControl()
        TourActivityWidgetLiveActivity()
    }
}
