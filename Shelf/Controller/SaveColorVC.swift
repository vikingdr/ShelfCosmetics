//
//  SaveColorVC.swift
//  Shelf
//
//  Created by Nathan Konrad on 30.06.15.
//  Copyright (c) 2015 Shelf. All rights reserved.
//

import UIKit
import MapKit
class SaveColorVC: BaseVC, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource{
    @IBOutlet weak var ratingView: RatingView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var optionalTextLabel: UILabel!
    @IBOutlet weak var writeDescriptionLabel: UILabel!
    @IBOutlet weak var rateAndDescribeLabel: UILabel!
    @IBOutlet weak var saveColorButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    var color : SColor?
    var textDescription : UITextView?
    let kDescriptionText = "Loving this new shade! \n #autumn #seasonal"
    let kDescriptionTextColor = UIColor(colorLiteralRed: 255, green: 255, blue: 255, alpha: 0.15)
    var bottomConstraintHeight : CGFloat = 0
    var coatsLabel : UILabel?
    var isObserverSet : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(SaveColorVC.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SaveColorVC.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(named: "Navigationbar")!.resizableImage(withCapInsets: UIEdgeInsetsMake(0, 0, 0, 0), resizingMode: .stretch), for: UIBarMetrics.default)
        
        NotificationCenter.default.addObserver(self, selector: #selector(SaveColorVC.launchedApp), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isObserverSet == false && textDescription != nil {
            textDescription!.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.new, context: nil)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        if isObserverSet == true {
            textDescription!.removeObserver(self, forKeyPath: "contentSize")
            isObserverSet = false
        }
    }
    
    func launchedApp(){
         view.endEditing(true)
        tableViewBottomConstraint.constant = 0
    }
    
    func setupTableView(){
        self.tableView.backgroundView = nil
        self.tableView.backgroundColor = UIColor.clear
        tableView.register(UINib(nibName: "SelectARatingCell", bundle: nil), forCellReuseIdentifier: "SelectARatingCell")
        tableView.register(UINib(nibName: "NumberOfCoatsCell", bundle: nil), forCellReuseIdentifier: "NumberOfCoatsCell")
        tableView.register(UINib(nibName: "LocationCell", bundle: nil), forCellReuseIdentifier: "LocationCell")
        tableView.register(UINib(nibName: "DescriptionCell", bundle: nil), forCellReuseIdentifier: "DescriptionCell")
        tableView.register(UINib(nibName: "LocationSelectedCell", bundle: nil), forCellReuseIdentifier: "LocationSelectedCell")

        tableView.register(UINib(nibName: "SaveCell", bundle: nil), forCellReuseIdentifier: "SaveCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    //keyboard hide
    func onTap (){
        self.view.endEditing(true)
    }
    
    // MARK: - save color
    @IBAction func onSave(_ sender: AnyObject) {

    }

    func setLocation(_ item : MKMapItem){
        color?.locationName = item.name
        let coordinate = item.placemark.coordinate
        color?.geopoint = PFGeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
        tableView.reloadRows(at: [IndexPath(item: 2, section: 0)], with: .automatic)
    }
    
    //MARK: UITableView Delegate Methods
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell!
        switch (indexPath.row ){
        case 0 :
            cell = tableView.dequeueReusableCell(withIdentifier: "SelectARatingCell") as! SelectARatingCell
            
            (cell as! SelectARatingCell).rating.returnFunc = ratingUpdated
            if let rating = color?.rating {
                (cell as! SelectARatingCell).rating.rating = rating
            }
            break
        case 1 :
            cell = setupNumberOfCoats()
            break
        case 2 :
            if color?.locationName == nil {
                cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell") as! LocationCell
                if let colorName = color?.locationName {
                    (cell as! LocationCell).selectALocation.text = colorName
                }
            }else{
                cell = tableView.dequeueReusableCell(withIdentifier: "LocationSelectedCell") as! LocationSelectedCell
                if let colorName = color?.locationName {
                    //let expectedSize = colorName
                    (cell as! LocationSelectedCell).selectALocation.text = colorName
                }
            }
            break
        case 3:
            cell = setupDescriptionCell()
            break
        case 4:
            cell = tableView.dequeueReusableCell(withIdentifier: "SaveCell") as! SaveCell
            (cell as! SaveCell).saveButton.addTarget(self, action: #selector(SaveColorVC.saveTapped), for: .touchUpInside)
            break;
        default:
            cell = UITableViewCell()
            break;
        }

        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        return cell
    }
    
    func saveTapped(){
        if (color?.rating == nil) {
            let alert = UIAlertView(title: "Rate Color", message: "Please rate this color before saving it", delegate: nil, cancelButtonTitle: "Ok")
            alert.show()
            return
        }
        
        //saving Color and back to tabbar
        color?.createAndSave()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.imagefooter?.isHidden = false
        self.dismiss(animated: true, completion: nil)
    }
    
    func setupNumberOfCoats() -> NumberOfCoatsCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NumberOfCoatsCell") as! NumberOfCoatsCell
        coatsLabel = cell.numberOfCoats
        if let colorV = color {
            if colorV.numberOfCoats == nil{
                colorV.numberOfCoats = 1
            }
            coatsLabel!.text = String(colorV.numberOfCoats!)
        }
        cell.minusButton.addTarget(self, action: #selector(SaveColorVC.minusSelected), for: .touchUpInside)
        cell.plusButton.addTarget(self, action: #selector(SaveColorVC.plusSelected), for: .touchUpInside)
        return cell
    }
    
    func setupDescriptionCell() -> DescriptionCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "DescriptionCell") as! DescriptionCell
        if textDescription != nil {
            //remove center text observer it if already exists
            textDescription!.removeObserver(self, forKeyPath: "contentSize")
            isObserverSet = false
        }
        
        textDescription = cell.textDescription
        textDescription!.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.new, context: nil)
        isObserverSet = true

        textDescription?.addDoneToolBar()
        textDescription?.delegate = self
        
        if color?.comment != nil && color?.comment != "" {
            textDescription!.text = color?.comment
        }
        centerTextView(textDescription!)
        
        return cell
    }
    
    //called when rating view gets updated
    func ratingUpdated( _ rating : Int){
        color?.rating = rating
    }
    
    func plusSelected(){
        if color != nil {
            if color?.numberOfCoats == nil {
                color?.numberOfCoats = 1
            }else {
                color?.numberOfCoats = color!.numberOfCoats! + 1
            }
            coatsLabel!.text = String(color!.numberOfCoats!)
            
        }
    }
    
    func minusSelected(){
        if color != nil {
            if color!.numberOfCoats == nil || color?.numberOfCoats == 0 {
                color!.numberOfCoats = 0
            }else {
                color?.numberOfCoats = color!.numberOfCoats! - 1
            }
            coatsLabel!.text = String(color!.numberOfCoats!)
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 120
        case 1:
            return 110
        case 2:
            return 62
        case 3:
            return 134
        case 4:
            return 75
        default:
            return 50
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let textView = object as! UITextView
        centerTextView(textView)
    }
    
    func centerTextView( _ textView : UITextView){
        var topCorrect = (textView.bounds.size.height - textView.contentSize.height * textView.zoomScale) / 2
        topCorrect = topCorrect < 0.0 ? 0.0 : topCorrect;
        textView.contentInset.top = topCorrect
    }
    
    // MARK: - NSNotification
    func keyboardWillShow(_ notification: Notification) {
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        
        let frame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        UIView.animate(withDuration: duration, animations: { () -> Void in
            self.bottomConstraintHeight = self.tableViewBottomConstraint.constant
            self.tableViewBottomConstraint.constant = frame.height - 54
            self.view.layoutIfNeeded()
        }, completion: { (finished: Bool) -> Void in
        }) 
    }
    
    func keyboardWillHide(_ notification : Notification) {
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        UIView.animate(withDuration: duration, animations: { () -> Void in
            self.tableViewBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        })
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2 {
            let storyboard: UIStoryboard = UIStoryboard(name: "CreateShelfie", bundle: nil)
            let whereAreYouVC = storyboard.instantiateViewController(withIdentifier: "WhereAreYouVC") as! WhereAreYouVC
            whereAreYouVC.returnCallback = setLocation
            self.view.endEditing(true)
            self.navigationController?.pushViewController(whereAreYouVC, animated: true)
        }
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == kDescriptionText{
            textView.text = ""
            textView.textColor = UIColor.white
        }
        
        let index = IndexPath(item: 3, section: 0)
        tableView.scrollToRow(at: index, at: .bottom, animated: true)
        textView.becomeFirstResponder()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = kDescriptionText
            textView.textColor = kDescriptionTextColor
        }
        textView.resignFirstResponder()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        color?.comment = textView.text
    }
    
}
