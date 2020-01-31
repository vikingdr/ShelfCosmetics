//
//  WhereAreYouVC.swift
//  Shelf
//
//  Created by Nathan Konrad on 9/19/16.
//  Copyright © 2016 Shelf. All rights reserved.
//

import UIKit
import MapKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class WhereAreYouVC: UIViewController, UITextFieldDelegate, MKMapViewDelegate, UISearchBarDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var placesTableView: UITableView!
    @IBOutlet weak var redoButton: UIButton!
    @IBOutlet weak var chooseButton: UIButton!

    @IBOutlet weak var redoButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var redoButtonHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var topTableViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchBarBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet weak var buttonsBottomConstraint: NSLayoutConstraint!
    
    //var placesClient: GMSPlacesClient?
    var currLocation: CLLocation?
    var locationManager : CLLocationManager?
    var places = [Place]()
    var searching = false
    let kConversionToFeet = 3.28084
    let kFeetInMile = 5280.0
    let kDelta = 100.0
    var search : MKLocalSearch?
    let screenSize = UIScreen.main.bounds
    var keyboardHeight : CGFloat = 0
    var previousText : String?
    var currPlace : MKMapItem?
    var returnCallback : ((MKMapItem) -> ())!
    var hasMovedToCurrentLocation = false
    var currentPlace : Place?
    var annotationView : ShelfAnnotationView?
    let kLocationTag = 0
   
    
    override func viewDidLoad() {
        setupTitle()

        setupSearchTextField()

        searchBarView.layer.cornerRadius = 5.0
        searchBarView.clipsToBounds = true
        
        redoButton.layer.cornerRadius = 5.0
        redoButton.clipsToBounds = true
        
        chooseButton.layer.cornerRadius = 5.0
        chooseButton.clipsToBounds = true
        
        setupTableView()
      
        setupNavigationBar()
        setupBarButtonItems()
        
        mapView.delegate = self
        searchBar.delegate = self

        chooseButton.setAttributedTitle(setupAttributedButtonText("CHOOSE"), for: UIControlState())
        redoButton.setAttributedTitle(setupAttributedButtonText("REDO"), for: UIControlState())
        
        setupSearchBar()
        locationManager = CLLocationManager()
        let textColor = UIColor(colorLiteralRed: 255, green: 255, blue: 255, alpha: 0.8)
        let attr = [ NSForegroundColorAttributeName : textColor,NSFontAttributeName : UIFont(name: "Avenir-Black", size: 13)!]
        
        UIBarButtonItem.my_appearanceWhenContained(in: UISearchBar.self).setTitleTextAttributes(attr, for: UIControlState())
        
        placesTableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)
        placesTableView.backgroundColor = UIColor(colorLiteralRed: 255, green: 255, blue: 255, alpha: 0.9)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //request location services
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager!.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == .authorizedAlways || status == .authorizedWhenInUse){
            manager.startUpdatingLocation()
            mapView.showsUserLocation = true
        }
    }
    
    func setupSearchBar(){
        let field = getSearchBarField(searchBar)
        if let searchBarField = field {
            
            searchBarField.backgroundColor = UIColor.clear
            searchBarField.textColor = UIColor.white
            let color = UIColor(colorLiteralRed: 255, green: 255, blue: 255, alpha: 0.5)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = NSTextAlignment.left

            let attributedString = NSAttributedString(string: createFormattedPlaceHolder("Tap to start typing..."), attributes: [NSForegroundColorAttributeName: color,NSParagraphStyleAttributeName: paragraphStyle,  NSBaselineOffsetAttributeName: NSNumber(value: 0 as Float)])
            
            searchBarField.attributedPlaceholder = attributedString
            searchBarField.layer.cornerRadius = 10
            searchBarField.textAlignment = .left
        }
        searchBar.setImage(UIImage(), for: .search, state: UIControlState())
        
        //Transparent background
        searchBar.backgroundImage = UIImage()
        searchBar.backgroundColor = UIColor.clear

        searchBar.setImage(UIImage(named: "clearIcon"), for: .clear, state: UIControlState())
        searchBar.setImage(UIImage(named: "clearIcon"), for: .clear, state: .highlighted)
    }
    
    func createFormattedPlaceHolder(_ text : String) -> String{
        var placeholder = ""
            if text.characters.last! != " " {
                let textField = UITextField.my_appearanceWhenContained(in: WhereAreYouVC.self)
                let font = UIFont(name: "Avenir-Black", size: 13.5)
                textField?.defaultTextAttributes = [NSFontAttributeName : font!, NSForegroundColorAttributeName : UIColor.white]
                // get the font attribute
                let attr = textField?.defaultTextAttributes
                
                // define a max size
                let maxSize = CGSize(width: UIScreen.main.bounds.size.width - 70 , height: 40)
                
                // get the size of the text
                let widthText = text.boundingRect( with: maxSize, options: .usesLineFragmentOrigin, attributes:attr, context:nil).size.width
                // get the size of one space
                let widthSpace = " ".boundingRect( with: maxSize, options: .usesLineFragmentOrigin, attributes:attr, context:nil).size.width
                let spaces = floor((maxSize.width - widthText) / widthSpace)
                // add the spaces
                let newText = text + ((Array(repeating: " ", count: Int(spaces)).joined(separator: "")))
                // apply the new text if nescessary
                if newText != text {
                    placeholder = newText
                }
            }
        return placeholder
    }
    
    func getSearchBarField(_ bar : UISearchBar) -> UITextField? {
        let svs = bar.subviews.flatMap { $0.subviews }
        guard let tf = (svs.filter { $0 is UITextField }).first as? UITextField else { return nil}
        return tf
    }
    

    func setupTableView(){
        placesTableView.delegate = self
        placesTableView.dataSource = self
        placesTableView.register(UINib(nibName: "MapSuggestionCell", bundle: nil), forCellReuseIdentifier: "MapSuggestionCell")
        placesTableView.tableFooterView = UIView()
        placesTableView.backgroundColor = UIColor.clear
        
        placesTableView.alpha = 0
        placesTableView.isHidden = true
        placesTableView.layer.cornerRadius = 5
        placesTableView.layer.masksToBounds = true
        placesTableView.separatorStyle = .none
        
    }
    
    func setupSearchTextField(){
        
        searchBar.layer.cornerRadius = 5.0
        searchBar.clipsToBounds = true
        // Indent textfield search
        _ = UIView(frame: CGRect(x: 0, y: 0, width: 26, height: 10))
        setupPlaceholderText()
    }
    
    func setupPlaceholderText(){
        let placeholderAttrString = NSMutableAttributedString(string: "Tap to start typing...")
        let placeholderRange = NSMakeRange(0, placeholderAttrString.length)
        placeholderAttrString.addAttribute(NSForegroundColorAttributeName, value: UIColor.white, range: placeholderRange)
        placeholderAttrString.addAttribute(NSFontAttributeName, value: UIFont(name: "Avenir-Black", size: 16)!, range: placeholderRange)
        placeholderAttrString.addAttribute(NSKernAttributeName, value: 0.8, range: placeholderRange)
        
    
        //searchBar.attributedPlaceholder = placeholderAttrString
        //searchTextField.addTarget(self, action: #selector(WhereAreYouVC.searchTextEntered(_:)), forControlEvents: UIControlEvents.EditingChanged)
        //searchTextField.returnKeyType = .Default
        
    }
    
    func setupAttributedButtonText(_ text : String) -> NSMutableAttributedString{
        
        let chooseTitle = NSMutableAttributedString(string: text)
        let range = NSMakeRange(0, chooseTitle.length)
        
        chooseTitle.addAttribute(NSKernAttributeName, value: 2.7, range: range)
        chooseTitle.addAttribute(NSForegroundColorAttributeName, value: UIColor.white, range: range)
    
        return chooseTitle
    }
    
    func calcSpacingForKeyboard() -> CGFloat{
        if navigationController != nil {
            let bottom = screenSize.height - searchBar.frame.height - 13 - keyboardHeight
            
            let final = bottom - UIApplication.shared.statusBarFrame.height - navigationController!.navigationBar.frame.size.height
            return final
        }
        return 0
    }
    
    @IBAction func redoSelected(_ sender: AnyObject) {
        searchBar.isHidden = false
        searchBar.text = ""
        buttonsView.isHidden = true
        placesTableView.isHidden = false
        mapView.showsUserLocation = true
        UIView.animate(withDuration: 0.5, animations: { 
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.placesTableView.alpha = 1
            self.searchBar.alpha = 1
            self.searchBarView.alpha = 1
            self.buttonsView.alpha = 0
        }) 
        
        searchBar.isHidden = false
        searchBarView.isHidden = false
        
        places.removeAll()
        searchBar.becomeFirstResponder()
        zoomToLocation(mapView.userLocation.location) { (completed) in
            self.setFocusToMiddleOfMap()
        }
    }
    
    func zoomToLocation(_ coordinates : CLLocation? , completion : ((Bool ) -> ())? = nil ){
        if let userLoc = coordinates {
            let region = MKCoordinateRegionMakeWithDistance(userLoc.coordinate, 300, 300)
            UIView.animate(withDuration: 1.0, animations: {
                self.mapView.region = region
                if let completion = completion{
                    completion(true)
                }
            })
        }
    }
    
    @IBAction func chooseSelected(_ sender: AnyObject) {
        returnCallback(currPlace!)
        navigationController?.popViewController(animated: true)
    }
    
    func setupBarButtonItems(){
        // Update navigationbaritem
        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 10, height: 18))
        backButton.setImage(UIImage(named: "backButton"), for: UIControlState())
        backButton.addTarget(self, action: #selector(WhereAreYouVC.backButtonPressed(_:)), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        print(navigationItem.leftBarButtonItem?.customView?.frame)
        let locateMeButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        locateMeButton.setImage(UIImage(named: "Locate Me"), for: UIControlState())
        locateMeButton.addTarget(self, action: #selector(WhereAreYouVC.locateMeButtonPressed(_:)), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: locateMeButton)
    }
    
    func setupTitle(){
        let attrString = NSMutableAttributedString(string: "WHERE ARE YOU?")
        let range = NSMakeRange(0, attrString.length)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        attrString.addAttribute(NSKernAttributeName, value: 4.6, range: range)
        attrString.addAttribute(NSForegroundColorAttributeName, value: UIColor.white, range: range)
        attrString.addAttribute(NSFontAttributeName, value: UIFont(name: "Avenir-Black", size: 14)!, range: range)
        attrString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: range)
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 215, height: 19))
        titleLabel.attributedText = attrString
        navigationItem.titleView = titleLabel
    }
    
    func setupNavigationBar(){
        self.navigationController?.navigationBar.alpha = 0.95
    }
    
    override func viewWillAppear(_ animated: Bool) {
       // mapView.myLocationEnabled = true
        //request location services
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager!.requestWhenInUseAuthorization()
        }
        mapView.showsUserLocation = true
        mapView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(WhereAreYouVC.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(WhereAreYouVC.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        

    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(_ notification: Notification) {
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        
        let frame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            self.placesTableView.isHidden = false
        keyboardHeight = frame.height
        calcSpacingForKeyboard()
        setFocusToMiddleOfMap()
        UIView.animate(withDuration: duration, animations: { () -> Void in
            self.searchBar.setImage(UIImage(named: "searchIcon"), for: .search, state: UIControlState())
            self.searchBar.showsCancelButton = true
            self.searchBarView.alpha = 1.0
            self.searchBarBottomConstraint.constant = self.keyboardHeight + 12
            self.buttonsBottomConstraint.constant = self.keyboardHeight + 17
            self.view.layoutIfNeeded()
        }, completion: { (finished: Bool) -> Void in
                self.calculateConstraintHeight()
                self.placesTableView.reloadData()
            UIView.animate(withDuration: 0.5, animations: { 
                self.placesTableView.isHidden = false
                self.placesTableView.alpha = 1
            })
            
        }) 
    }
    
    func keyboardWillHide(_ notification: Notification) {
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        keyboardHeight = 0
        UIView.animate(withDuration: duration, animations: {
            self.searchBar.setImage(UIImage(), for: .search, state: UIControlState())
            self.searchBar.showsCancelButton = false
            self.searchBarView.alpha = 0.9
            self.searchBarBottomConstraint.constant = 12
            self.buttonsBottomConstraint.constant = 17
            self.placesTableView.alpha = 0
            self.view.layoutIfNeeded()
            }, completion: { (finished) in
            self.placesTableView.isHidden = true
        }) 
    }
    
    // MARK: - IBActions
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func locateMeButtonPressed(_ sender: AnyObject) {
        searchBar.resignFirstResponder()
        zoomToLocation(mapView.userLocation.location)
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let annotationView = mapView.view(for: userLocation)
        annotationView?.canShowCallout = false
        updateZoom(userLocation.location)
    }
    
    func updateZoom(_ location : CLLocation?){
        if let lastLoc = location {
            if distanceInMilesFrom(lastLoc.coordinate) > kDelta || hasMovedToCurrentLocation == false {
               
                if let location = location {
                     let geo = CLGeocoder()
                        geo.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                        if let error = error {
                            print("Error occurred geocoding \(error.localizedDescription)")
                        }
                            if let currentLocation = placemarks?.last {
                                let mPlacemark = MKPlacemark(coordinate: location.coordinate, addressDictionary:   currentLocation.addressDictionary as! [String : AnyObject]?)
                                let mapItem = MKMapItem(placemark: mPlacemark)
                                self.currentPlace = Place(place: mapItem, distance: CLLocationDistance())
                                if let currPlace = self.currentPlace {
                                    let annotation = MKPointAnnotation()
                                    annotation.coordinate = currPlace.place.placemark.coordinate
                                    //self.mapView.removeAnnotations(self.mapView.annotations)
                                    //self.mapView.addAnnotation(annotation)
                                }
                                
                            }
                    })
                }
                //Zooms in and sets current location
                if let userLoc = mapView.userLocation.location {
                    let region = MKCoordinateRegionMakeWithDistance(userLoc.coordinate, 300, 300)
                        self.mapView.region = region
                }
                //zoomToLocation()
                hasMovedToCurrentLocation = true
            }
        }
        currLocation = location
    }
    
    // MARK: - UITextField Delegate
    func searchTextEntered(_ text: String) {
        if (checkForDeleteAndSearch(text) == true){
            self.calculateConstraintHeight()
            self.placesTableView.reloadData()
            return
        }
        
        placesTableView.isHidden = false
        searching = true
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = text

        if let location = currLocation {
            request.region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001))
        }else {
            request.region = mapView.region
        }
        
        search = MKLocalSearch(request: request)
        places.removeAll()
        
        beginSearch(search!)
    }
    
    func checkForDeleteAndSearch(_ text : String) -> Bool{
        
        previousText = text
        
        if emptyTextCase(text) == true {
            return true
        }
        
        UIView.animate(withDuration: 0.5, animations: {
            self.placesTableView.isHidden = false
            self.placesTableView.alpha = 1
        })

        return false
    }
    
    func deleteCharactersCase(_ text : String) -> Bool{
        
        if previousText != nil && previousText?.characters.count > text.characters.count {

            UIView.animate(withDuration: 0.5, animations: {
               // self.placesTableView.hidden = true
               // self.placesTableView.alpha = 0
                }, completion: { (completed) in
                    self.placesTableView.reloadData()
                    self.places.removeAll()
            })
            
            if search != nil {
                search?.cancel()
            }
            previousText = text
            return true
        }
        return false
    }
    
    func emptyTextCase(_ text : String) -> Bool{
        var shouldEndSearch = false
        if text.isEmpty == true {
            UIView.animate(withDuration: 0.5, animations: {
                //self.placesTableView.hidden = true
                //self.placesTableView.alpha = 0
                }, completion: { (completed) in
                    self.placesTableView.reloadData()
                    self.places.removeAll()
            })
            
            if search != nil {
                search?.cancel()
            }
            shouldEndSearch = true
            return shouldEndSearch
        }
        else if searching == true {
            if search != nil {
                search?.cancel()
            }
        }
        return shouldEndSearch
    }
    
    func beginSearch( _ search : MKLocalSearch){
        search.start { (response, error) in
            guard let response = response else {
                print("error occurred while searching \(error)")
                return
            }
            
            for item in response.mapItems {
                let newPlace = Place(place: item, distance: self.distanceInMilesFrom(item.placemark.coordinate))
                if !self.places.contains(newPlace){
                    self.insertAtPosition(newPlace)
                    self.searching = false
                }
            }
            
            self.placesTableView.reloadData()
            self.calculateConstraintHeight()
        }
    }
    
    func calculateConstraintHeight(){
        var tvHeight = self.calcSpacingForKeyboard();
        var numberOfRows = self.places.count
        if currLocation == nil {
            numberOfRows = numberOfRows - 1
        }

        tvHeight = tvHeight - CGFloat(((numberOfRows) * 50)) + 7
        if numberOfRows >= 0 {
            tvHeight = tvHeight - 12
        }
        var newHeight : CGFloat = 0.0
        if tvHeight < 128 {
            newHeight = 128.0
        }else{
            newHeight = tvHeight
        }
        
        UIView.animate(withDuration: 0.5, animations: {
            self.topTableViewConstraint.constant = newHeight
            self.placesTableView.setNeedsUpdateConstraints()
            self.placesTableView.layoutIfNeeded()
        })
        
    }
    
    func insertAtPosition(_ place : Place) -> Int{
        var position = -1;
        var i = 0;

        while i < places.count {
            if place.distance <= places[i].distance {
                position = i;
                places.insert(place, at: i)
                return position
            }
            
            i = i + 1;
        }
        
        position = 0;
        places.append(place)
        return position
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        // Fetch location
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchBar.resignFirstResponder()
        return true
    }

    
    // MARK: - Helper functions
    func distanceInMilesFrom(_ otherCoord: CLLocationCoordinate2D) -> CLLocationDistance {
        if let firstLoc = currLocation {
            let secondLoc = CLLocation(latitude: otherCoord.latitude, longitude: otherCoord.longitude)
            return firstLoc.distance(from: secondLoc)
        }
        
        return 0
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let pinView = MKAnnotationView()
        pinView.image = UIImage(named: "RedPinIcon")
        pinView.canShowCallout = false

        if annotation.title! != currPlace?.name{
            pinView.tag = kLocationTag
        }else{
            pinView.tag = -1
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if view.tag == kLocationTag {
            return
        }
        annotationView =  Bundle.main.loadNibNamed("ShelfAnnotationView", owner: self, options: nil)?.first as? ShelfAnnotationView
        annotationView!.frame = CGRect(x: -88, y: -66, width: annotationView!.frame.size.width, height: annotationView!.frame.size.height)
        annotationView!.alpha = 0
        if let place = currPlace, let name = place.name {
            annotationView!.name.attributedText = setTitleAttributedString(name)
        }
        view.addSubview(annotationView!)
        UIView.animate(withDuration: 0.3, animations: {
            self.annotationView?.alpha = 1
        }) 
    }
    
    func setTitleAttributedString(_ str : String ) -> NSMutableAttributedString{
        let kerningDefaultTitle = 0.6
        let ph = NSMutableAttributedString(string: str)
        let color = UIColor(colorLiteralRed: 255, green: 255, blue: 255, alpha: 1)
        ph.addAttribute(NSForegroundColorAttributeName, value: color, range: NSMakeRange(0, ph.length))
        ph.addAttribute(NSKernAttributeName, value: kerningDefaultTitle, range:  NSMakeRange(0, ph.length))
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        ph.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSMakeRange(0, ph.length))
        let font = UIFont(name: "Avenir-Black", size: 13.5)
        ph.addAttribute(NSFontAttributeName, value: font!, range: NSMakeRange(0, ph.length))
        return ph
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if let annoView = self.annotationView {
            UIView.animate(withDuration: 0.3, animations: {
                annoView.alpha = 0
            }, completion: { (completed) in
                annoView.removeFromSuperview()
            })
        }
    }

    func setFocusToMiddleOfMap(){
        let offset = UIOffsetMake(0, (placesTableView.frame.size.height / 2))
        var pt = mapView.convert(mapView.userLocation.coordinate, toPointTo: mapView)
        pt.y += offset.vertical
        
        let newCenter = mapView.convert(pt, toCoordinateFrom: mapView)
        mapView.setCenter(newCenter, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count == 0 {
            places.removeAll()
            placesTableView.reloadData()
        }
        
        searchTextEntered(searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        searchBar.text = ""
        places.removeAll()
        placesTableView.reloadData()
    }
}


extension WhereAreYouVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if places.count == 1 {
            placesTableView.isScrollEnabled = false
            placesTableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)
        }else{
            placesTableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)
            placesTableView.isScrollEnabled = true
        }
        return places.count + 1 // one additional for current city
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MapSuggestionCell") as! MapSuggestionCell

        if indexPath.row == 0  {
            if currLocation != nil {
                if let cityState = getCityAndState() {
                    currentPlace?.place.name = cityState
                        cell.placeName.text = cityState
                        cell.myLocation.isHidden = false
                        cell.distance.isHidden = true
                        cell.milesLabel.isHidden = true
                }
            }
        }else
            if (places.count + 1) > indexPath.row {
            let indexRow = indexPath.row - 1
            cell.placeName.text = places[indexRow].place.name
            var distanceCalc = (places[indexRow].distance * kConversionToFeet)/kFeetInMile
            cell.distance.text = String(format: "%.2f", distanceCalc.roundToPlaces(2))
        }
        cell.backgroundColor = UIColor.clear
        //cell.backgroundColor =  UIColor(red: 255, green: 255, blue: 255, alpha: 0.9)
        return cell
    }
    
    func getCityAndState() -> String?{
        if let dict = currentPlace?.place.placemark.addressDictionary as! [ String : AnyObject]? {
            if let subLocatlity = dict["SubLocality"] as? String {
                if let state = dict["State"] as? String{
                    return subLocatlity + ", " + state
                }
            }
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == places.count - 1 {
            return 50
        }
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row  < places.count + 1 {
            if indexPath.row == 0 && currLocation != nil {
                currPlace = currentPlace?.place
            }else {

                var index = indexPath.row - 1
                if currLocation == nil {
                    index = index + 1
                }
                currPlace = places[index].place
            }
            if currPlace != nil {
                let annotation = MKPointAnnotation()
                annotation.coordinate = currPlace!.placemark.coordinate
                annotation.title = currPlace!.name
            
                mapView.showsUserLocation = false
                mapView.removeAnnotations(mapView.annotations)
                mapView.addAnnotation(annotation)
                
                
                let centerCoordinate = currPlace!.placemark.coordinate
                //Zoom to map
                let location = CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
                
                zoomToLocation(location)
                mapView.selectAnnotation(annotation, animated: true)
                places.removeAll()
                    
                UIView.animate(withDuration: 0.5, animations: {
                    self.placesTableView.alpha = 0
                    self.searchBar.alpha = 0
                    self.searchBarView.alpha = 0
                    self.buttonsView.alpha = 1
                }, completion: { (completed) in
                    self.view.endEditing(true)
                    self.placesTableView.isHidden = true
                    self.searchBar.isHidden = true
                    self.searchBarView.isHidden = true
                    self.buttonsView.isHidden = false
                })
            }
        }
    }
}


