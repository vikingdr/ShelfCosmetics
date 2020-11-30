//
//  MapVC.swift
//  Shelf
//
//  Created by Matthew James on 10/10/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import UIKit
import MapKit
class MapVC: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapForLocation: MKMapView!
    
    var geopoint : PFGeoPoint?
    var locationName : String?
    
    //@IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        mapForLocation.delegate = self
        title = "Shelfie Location"
        let font = UIFont(name: "Avenir-Black", size: 14)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white, NSFontAttributeName : font!]
        let del = UIApplication.shared.delegate as! AppDelegate
        del.imagefooter?.isHidden = true
        tabBarController?.tabBar.isHidden = true
        
        addLocationToMap()
        addBackButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let del = UIApplication.shared.delegate as! AppDelegate
        del.imagefooter?.isHidden = false
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
    
    func addBackButton(){
        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 18))
        backButton.setImage(UIImage(named: "backButton"), for: UIControlState())
        backButton.addTarget(self, action: #selector(MapVC.backButtonPressed(_:)), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    func addLocationToMap(){
        if let geoPt = geopoint {
            let coord = CLLocationCoordinate2D(latitude: geoPt.latitude, longitude: geoPt.longitude)
            let region = MKCoordinateRegion(center: coord, span: MKCoordinateSpan(latitudeDelta: 0.0014, longitudeDelta: 0.0014))
            mapForLocation.region = region
            let ptAn = MKPointAnnotation()
            ptAn.coordinate = coord
            
            let annotation = MKAnnotationView(annotation: ptAn, reuseIdentifier: nil)
            annotation.image = UIImage(named: "RedPinIcon")
            mapForLocation.addAnnotation(annotation.annotation!)
            mapForLocation.selectAnnotation(mapForLocation.annotations.first!, animated: false)
        }
        
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {

        let annotationView =  Bundle.main.loadNibNamed("ShelfAnnotationView", owner: self, options: nil)?.first as? ShelfAnnotationView
        annotationView!.frame = CGRect(x: -88, y: -66, width: annotationView!.frame.size.width, height: annotationView!.frame.size.height)
        annotationView!.alpha = 0
        if let name = locationName {
            annotationView!.name.attributedText = setTitleAttributedString(name)
        }
        view.addSubview(annotationView!)
        UIView.animate(withDuration: 0.3, animations: {
            annotationView?.alpha = 1
        }) 
    }
    
    func setTitleAttributedString(_ str : String ) -> NSMutableAttributedString{
        let kerningDefaultTitle = 0.7
        let ph = NSMutableAttributedString(string: str)
        let color = UIColor(colorLiteralRed: 255, green: 255, blue: 255, alpha: 1)
        ph.addAttribute(NSForegroundColorAttributeName, value: color, range: NSMakeRange(0, ph.length))
        ph.addAttribute(NSKernAttributeName, value: kerningDefaultTitle, range:  NSMakeRange(0, ph.length))
        let font = UIFont(name: "Avenir-Black", size: 13.5)
        ph.addAttribute(NSFontAttributeName, value: font!, range: NSMakeRange(0, ph.length))
        return ph
    }
    
    func backButtonPressed(_ sender : AnyObject?){
        navigationController?.popViewController(animated: true)
    }

}
