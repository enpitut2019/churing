//
//  ViewController.swift
//  location
//
//  Created by apple on 2019/08/01.
//  Copyright © 2019 TakumaHidaka. All rights reserved.
//
//import UIKit
//import CoreLocation
//class ViewController: UIViewController {
//    override func viewDidLoad() {
//        super.viewDidLoad()
// Do any additional setup after loading the view.
//    }
//}
import CoreLocation
import UIKit
import GoogleMaps
import UserNotifications

// グローバル変数集
let textFileName1 = "xpoint.txt" //経度記憶用のテキストファイル名
let textFileName2 = "ypoint.txt" //緯度記憶用のテキストファイル名
var initialText1 = String("000.0000") //初期テキスト
var initialText2 = String("000.0000") //初期テキスト
var contents1 = String("000.0000") //経度表示用のグローバル変数
var contents2 = String("000.0000") //緯度表示用のグローバル変数
var point1 = String("point1")
var point2 = String("point2")
var count = 0 // バックグラウンド取得が行われた数
var stopcnt = 1 // 止まっている状態から再起動した時にその場を取得しないようにするためのフラグ
var endcnt = 0 // 自転車を止めた時に歩いたと予想される時間
var fastcnt = -10 // 自転車以上の速度で移動した時間
var pointsx:[Double] = [0,1,2,3,4,5,6,7,8,9,10] // 緯度を記録するための配列
var pointsy:[Double] = [0,1,2,3,4,5,6,7,8,9,10] // 経度を記録するための配列
var distance = 0.0 // 座標２点間の距離

//通知用オブジェクト
var year:String = ""
var month:String = ""
var day:String = ""
var hour:String = ""
var minute:String = ""
var second:String = ""
var pm:String = ""
var text:String = ""


func readingf(){
    if let documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
        // ディレクトリのパスにファイル名をつなげてファイルのフルパスを作る
        let targetTextFilePath1 = documentDirectoryFileURL.appendingPathComponent(textFileName1) //経度用
        let targetTextFilePath2 = documentDirectoryFileURL.appendingPathComponent(textFileName2) //緯度用
        //  テキストファイルを読み込む（デバッグ用）
        do {
            contents1 = try String(contentsOf: targetTextFilePath1, encoding: String.Encoding.utf8) //経度用のテキストファイルから経度を読み取る
            contents2 = try String(contentsOf: targetTextFilePath2, encoding: String.Encoding.utf8) //緯度用のテキストファイルから緯度を読み取る
            print("reading")
        } catch let error as NSError {
            print("failed to read: \(error)") //例外処理
        }
    }
}

func writingf(text1: String, text2: String){
    if let documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
        // ディレクトリのパスにファイル名をつなげてファイルのフルパスを作る
        let targetTextFilePath1 = documentDirectoryFileURL.appendingPathComponent(textFileName1) //経度用
        let targetTextFilePath2 = documentDirectoryFileURL.appendingPathComponent(textFileName2) //緯度用
        //  テキストファイルを作成
        do {
            try text1.write(to: targetTextFilePath1, atomically: true, encoding: String.Encoding.utf8) //経度を書き込み（上書き）
            try text2.write(to: targetTextFilePath2, atomically: true, encoding: String.Encoding.utf8) //緯度を書き込み（上書き）
            print("writing")
        }catch let error as NSError {
            print("failed to write: \(error)") //例外処理
        }
    }
}


class ViewControllerA: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    //地図の表示切替用の変数群
    @IBOutlet weak var PickerView: UIPickerView!
    @IBOutlet weak var displaybutton: UIButton!
    @IBAction func DisplayButton(_ sender: Any) {
        if PickerView.isHidden == true{
            PickerView.isHidden = false
            displaybutton.setTitle("決定", for:UIControl.State.normal )
        }
        else{
            PickerView.isHidden = true
            displaybutton.setTitle("見た目を変える", for:UIControl.State.normal )
        }

    }
  
    @IBAction func Resetbtn(_ sender: Any) {
        initialText1 = "999.0000" //初期化テキスト
        initialText2 = "999.0000" //初期化テキスト
        writingf(text1: initialText1, text2: initialText2)
        readingf()
    }
    
    let dataList = ["通常", "航空写真", "ハイブリット", "地形", "なし"]
    
    // グーグルマップの設定をする変数
    var googleMap : GMSMapView!
    let marker: GMSMarker = GMSMarker()
    
    override func viewDidLoad() {
        // スーパークラス
        super.viewDidLoad()
        
        // Delegate設定
        PickerView.delegate = self
        PickerView.dataSource = self
        
        readingf()
        
        let latitude = atof(contents1)
        let longitude = atof(contents2)
        self.view.addSubview(MakeMap(state: .normal, latitude: latitude, longitude: longitude, zoom: 18.25, width: self.view.bounds.width, height: self.view.bounds.height/2))
        
    }
    
    //PickerViewに必要な関数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataList.count
    }
    
    // UIPickerViewの最初の表示
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        return dataList[row]
    }
    
    // UIPickerViewのRowが選択された時の挙動
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        
        if dataList[row] == "通常"{
            googleMap.mapType = .normal
        }else if dataList[row] == "航空写真"{
            googleMap.mapType = .satellite
        }else if dataList[row] == "ハイブリット"{
            googleMap.mapType = .hybrid
        }else if dataList[row] == "地形"{
            googleMap.mapType = .terrain
        }else if dataList[row] == "なし"{
            googleMap.mapType = .none
        }
        
    }
    
    
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    func MakeMap(state: GMSMapViewType, latitude: Double, longitude: Double,zoom: Float,width: CGFloat, height: CGFloat)->GMSMapView{
        googleMap = GMSMapView(frame: CGRectMake(0, 0,width,height))
        googleMap.mapType = state
        googleMap.tag = 10
        googleMap.isMyLocationEnabled = true
        // MapViewの現在地ボタンを有効にする.
        googleMap.settings.myLocationButton = true
        // MapViewにカメラを追加.
        let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: latitude,longitude: longitude, zoom: zoom)
        googleMap.camera = camera
        //マーカーの作成
        marker.position = CLLocationCoordinate2DMake(latitude, longitude)
        marker.map = googleMap
        return googleMap
    }
    
}

class ViewController: UIViewController, CLLocationManagerDelegate  {
    // グーグルマップの設定をする変数
    var googleMap : GMSMapView!
    
    //エラー用の座標
    let latitude: CLLocationDegrees = 35.681541
    let longitude: CLLocationDegrees = 139.767136
    
    let marker: GMSMarker = GMSMarker()
    
    // 位置情報取得のための変数
    var locationManager: CLLocationManager!
    
    // 起動時に実行される関数
    override func viewDidLoad() {
        // スーパークラス
        super.viewDidLoad()
        
        // インスタンスの生成
        locationManager = CLLocationManager()
        
        // CLLocationManagerDelegateプロトコルを実装するクラスを指定する
        locationManager.delegate = self
        
        // 正規の座標を取得している時
        readingf()
        print("test = \(contents1)")
        if atof(contents1) != 999 {
            print("OK")
            Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(ViewController.change_map), userInfo: nil, repeats: false)
        }
        
        // バックグラウンド処理で位置情報を取得するための下準備
        locationManager = CLLocationManager.init()
        locationManager.allowsBackgroundLocationUpdates = true; // バックグランドモードで使用する場合YESにする必要がある
        locationManager.desiredAccuracy = kCLLocationAccuracyBest; // 位置情報取得の精度
        //locationManager.activityType = .automotiveNavigation
        locationManager.distanceFilter = -1; // 位置情報取得する間隔、1m単位とする
        locationManager.delegate = self as CLLocationManagerDelegate
        // 位置情報の認証チェック
        let status = CLLocationManager.authorizationStatus()
        if (status == .notDetermined) {
            print("許可、不許可を選択してない");
            // 常に許可するように求める
            locationManager.requestAlwaysAuthorization();
        }
        else if (status == .restricted) {
            print("機能制限している")
        }
        else if (status == .denied) {
            print("許可していない")
        }
        else if (status == .authorizedWhenInUse) {
            print("このアプリ使用中のみ許可している");
            locationManager.startUpdatingLocation()
        }
        else if (status == .authorizedAlways) {
            print("常に許可している");
            locationManager.startUpdatingLocation()
        }
    }
    
    @objc func change_map(){
        // 地図の画面へ移動
        change_segue(move: "second")
    }
    
    
    func change_segue(move: String){
        let storyboard: UIStoryboard = self.storyboard!
        let second = storyboard.instantiateViewController(withIdentifier: move)
        self.present(second, animated: false, completion:nil )
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //  「経度」ラベルに対応
    @IBOutlet weak var content: UILabel!
    //  「緯度」ラベルに対応
    @IBOutlet weak var content2: UILabel!
    
    //  「位置を登録」ボタンに対応
    @IBAction func button(_ sender: Any) {
        // 書き込み用の座標を格納
        initialText1 = point1 //経度用
        initialText2 = point2 //緯度用
        writingf(text1: initialText1, text2: initialText2)
        
        alert()
    }
    
    
    
    @IBAction func review(_ sender: Any) {
        if atof(contents1) != 999 {
            //まずは、同じstororyboard内であることをここで定義します
            let storyboard: UIStoryboard = self.storyboard!
            //ここで移動先のstoryboardを選択(今回の場合は先ほどsecondと名付けたのでそれを書きます)
            let second = storyboard.instantiateViewController(withIdentifier: "second")
            //ここが実際に移動するコードとなります
            self.present(second, animated: true, completion: nil)
        }
    }
    
    @IBAction func watch_map(_ sender: UIButton) {
        self.view.addSubview(googleMap)
    }
    //このバージョンではCGRectMakeが使えないためWrapする関数を作成して回避する。
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    @IBAction func back(segue: UIStoryboardSegue) {
        
    }
    
    func alert(){
        let alui = UIAlertController(title: "通知設定", message: "通知するようにしますか?", preferredStyle: UIAlertController.Style.alert)
        let btn_yes = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler:
        {
            (action: UIAlertAction!) in
            self.change_segue(move: "alert")
        }
        )
        let btn_no = UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler:
        {
            (action: UIAlertAction!) in
            self.change_segue(move: "second")
        }
        )
        alui.addAction(btn_no)
        alui.addAction(btn_yes)
        
        present(alui, animated: true, completion: nil)
    }
    
    // 位置情報が取得されると呼ばれる
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 最新の位置情報を取得 locationsに配列で入っている位置情報の最後が最新となる
        let location : CLLocation = locations.last!;
        point1 = "\(location.coordinate.latitude)"
        point2 = "\(location.coordinate.longitude)"
        count += 1
        // 配列の処理
        pointsx.append(atof(point1))
        pointsx.removeFirst()
        pointsy.append(atof(point2))
        pointsy.removeFirst()
        // 緯度経度をラジアンに変換
        let currentLa   = (pointsx.first!+pointsx[1]+pointsx[2])/3 * Double.pi / 180
        let currentLo   = (pointsy.first!+pointsy[1]+pointsy[2])/3 * Double.pi / 180
        let targetLa    = (pointsx.last!+pointsx[9]+pointsx[8])/3 * Double.pi / 180
        let targetLo    = (pointsy.last!+pointsy[9]+pointsy[8])/3 * Double.pi / 180
        // 緯度差
        let radLatDiff = currentLa - targetLa
        // 経度差算
        let radLonDiff = currentLo - targetLo
        // 平均緯度
        let radLatAve = (currentLa + targetLa) / 2.0
        // 測地系による値の違い
        // 赤道半径
        // let a = 6378137.0  world
        let a = 6377397.155 // japan
        // 極半径
        // let b = 6356752.314140356 world
        let b = 6356078.963 // japan
        // 第一離心率^2
        let e2 = (a * a - b * b) / (a * a)
        // 赤道上の子午線曲率半径
        let a1e2 = a * (1 - e2)
        let sinLat = sin(radLatAve);
        let w2 = 1.0 - e2 * (sinLat * sinLat);
        // 子午線曲率半径m
        let m = a1e2 / (sqrt(w2) * w2);
        // 卯酉線曲率半径 n
        let n = a / sqrt(w2)
        // 算出
        let t1 = m * radLatDiff
        let t2 = n * cos(radLatAve) * radLonDiff
        distance = sqrt((t1 * t1) + (t2 * t2))
        
        //print("d=\(distance) || c=\(count) e=\(endcnt) f=\(fastcnt) s=\(stopcnt)")
        // DocumentディレクトリのfileURLを取得
        if distance < 6 && endcnt < 10 && stopcnt == 0 {
            writingf(text1: point1, text2: point2)
            readingf()
            fastcnt = 0
        } else if distance < 22.5 {
            endcnt += 1
        } else {
            if fastcnt > 10 {
                endcnt = 0
                stopcnt = 0
            }
            fastcnt += 1
        }
    }
    // 位置情報の取得に失敗すると呼ばれる
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
    // デバッグ用（バックグラウンド処理のタイプ）
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == .restricted) {
            print("機能制限している");
        }
        else if (status == .denied) {
            print("許可していない");
        }
        else if (status == .authorizedWhenInUse) {
            print("このアプリ使用中のみ許可している");
            locationManager.startUpdatingLocation();
        }
        else if (status == .authorizedAlways) {
            print("常に許可している");
            locationManager.startUpdatingLocation();
        }
    }
    
}

class AlertViewController: UIViewController{
    
    @IBOutlet weak var picker: UIDatePicker!
    
    override func viewDidLoad() {
        // スーパークラス
        super.viewDidLoad()
    }
    
    @IBAction func closebtn(_ sender: Any) {
        // 通知許可ダイアログを表示
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            // エラー処理
        }
        // 通知内容の設定
        let content = UNMutableNotificationContent()
        
        content.title = NSString.localizedUserNotificationString(forKey: "駐ring", arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: "おーーい！！そこの君！！！もうすぐ自転車に乗る時間だよ！忘れてたでしょ？絶対そうだと思ったよ。もうほんとに感謝してくれよな（ ｉ _ ｉ ）", arguments: nil)
        content.sound = UNNotificationSound.default
        // 日付のフォーマット
        let formatter = DateFormatter()
        formatter.dateFormat = "yy"
        year = "20"+"\(formatter.string(from: picker.date))"
        formatter.dateFormat = "MM"
        month = "\(formatter.string(from: picker.date))"
        formatter.dateFormat = "dd"
        day = "\(formatter.string(from: picker.date))"
        formatter.dateFormat = "HH"
        hour = "\(formatter.string(from: picker.date))"
        formatter.dateFormat = "mm"
        minute = "\(formatter.string(from: picker.date))"
        formatter.dateFormat = "ss"
        second = "\(formatter.string(from: picker.date))"
        text = year + "年" + month + "月" + day + "日" + hour + "時" + minute + "分"
        
        //
        var myDateComponents = DateComponents()
        
        myDateComponents.year = Int(year)
        myDateComponents.month = Int(month)
        myDateComponents.day = Int(day)
        myDateComponents.hour = Int(hour)
        myDateComponents.minute = Int(minute)
        //
        let trigger = UNCalendarNotificationTrigger(dateMatching: myDateComponents, repeats: false)
        //
        let request = UNNotificationRequest(identifier: " Identifier", content: content, trigger: trigger)
        //
        // 通知を登録
        center.add(request) { (error : Error?) in
            if error != nil {
                // エラー処理
            }
        }
        change_segue(move: "second")
    }
    
    func change_segue(move: String){
        let storyboard: UIStoryboard = self.storyboard!
        let second = storyboard.instantiateViewController(withIdentifier: move)
        self.present(second, animated: false, completion:nil )
    }
}
