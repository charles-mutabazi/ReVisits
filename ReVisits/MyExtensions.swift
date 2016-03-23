//
//  MyMapView.swift
//  IkazeApp1
//
//  Created by Charl on 1/14/16.
//  Copyright © 2016 Octans Corp. All rights reserved.
//

import Foundation
import MapKit
import FBAnnotationClusteringSwift

import SystemConfiguration

public class Reachability {
    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
}

    
    extension VisitsMapViewController : FBClusteringManagerDelegate {
        
        func cellSizeFactorForCoordinator(coordinator:FBClusteringManager) -> CGFloat{
            return 3
        }
    }
    
    extension VisitsMapViewController : MKMapViewDelegate {
        
        func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool){
            NSOperationQueue().addOperationWithBlock({
                let mapBoundsWidth = Double(self.mapView.bounds.size.width)
                let mapRectWidth:Double = self.mapView.visibleMapRect.size.width
                let scale:Double = mapBoundsWidth / mapRectWidth
                let annotationArray = self.clusteringManager.clusteredAnnotationsWithinMapRect(self.mapView.visibleMapRect, withZoomScale:scale)
                self.clusteringManager.displayAnnotations(annotationArray, onMapView:self.mapView)
            })
        }
        
        func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
            
            var reuseId = ""
            if annotation.isKindOfClass(FBAnnotationCluster) {
                reuseId = "Cluster"
                var clusterView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
                clusterView = FBAnnotationClusterView(annotation: annotation, reuseIdentifier: reuseId, options: nil)
                return clusterView
            } else {
                if let annotation = annotation as? VisitAnnotations {
                    reuseId = "Pin"
                    //var view: MKPinAnnotationView
                    var view: MKAnnotationView
                    if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
                        as? MKPinAnnotationView { // 2
                            dequeuedView.annotation = annotation
                            view = dequeuedView
                    } else {
                        // 3
                        view = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                        view.canShowCallout = true
                        //view.calloutOffset = CGPoint(x: -5, y: 5)
                        view.rightCalloutAccessoryView = UIButton(type: UIButtonType.DetailDisclosure) as UIView
                        view.image = UIImage(named: "purple_dot")
                    }
                    return view
                }
                
                return nil
            }
        }
        
        
        //for drawing reddish circles
        func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
            let circle = MKCircleRenderer(overlay: overlay)
            circle.strokeColor = UIColor.redColor()
            circle.fillColor = UIColor(red: 255, green: 0, blue: 0, alpha: 0.1)
            circle.lineWidth = 1
            return circle
        }
        
        
//        func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        
//            var region = mapView.region
//            region.center = mapView.userLocation.coordinate
//            region.span = MKCoordinateSpanMake(0.05, 0.05)
//            
//            mapView.setRegion(region, animated: true)
            
            //mapView.showAnnotations([VisitedPlace], animated: true)
//        }
    }
