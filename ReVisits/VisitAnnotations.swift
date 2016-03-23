//
//  MyPlaces.swift
//  IkazeApp1
//
//  Created by Charl on 1/14/16.
//  Copyright © 2016 Octans Corp. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

public class VisitAnnotations: NSObject {
    public var title: String? = ""
    public var subtitle: String? = ""
    public var coordinate = CLLocationCoordinate2D(latitude: 39.208407, longitude: -76.799555)
}

extension VisitAnnotations : MKAnnotation {
    
}
