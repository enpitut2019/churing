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
var contents1 = String("テスト\n用\nテキスト1") //経度表示用のグローバル変数
var contents2 = String("テスト\n用\nテキスト2") //緯度表示用のグローバル変数
var point1 = String("point1")
var point2 = String("point2")

//通知用オブジェクト
var year:String = ""
var month:String = ""
var day:String = ""
var hour:String = ""
var minute:String = ""
var second:String = ""
var pm:String = ""
var text:String = ""


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
    
        if let documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
            // ディレクトリのパスにファイル名をつなげてファイルのフルパスを作る
            let targetTextFilePath1 = documentDirectoryFileURL.appendingPathComponent(textFileName1) //経度用
            let targetTextFilePath2 = documentDirectoryFileURL.appendingPathComponent(textFileName2) //緯度用
            do {
                contents1 = try String(contentsOf: targetTextFilePath1, encoding: String.Encoding.utf8)
                contents2 = try String(contentsOf: targetTextFilePath2, encoding: String.Encoding.utf8)
            } catch let error as NSError {
                print("failed to read: \(error)") //例外処理
            }
        }
        
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

class ViewController: UIViewController {
    
    @IBOutlet weak var tt: UILabel!
    
    @IBAction func btntap(_ sender: Any) {
        picker.isHidden = false
        closebtn.isHidden = false
        
    }
    
    @IBAction func closebtn(_ sender: Any) {
        closebtn.isHidden = true
        picker.isHidden = true
        
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
     
        
        var myDateComponents = DateComponents()
        
        myDateComponents.year = Int(year)
        myDateComponents.month = Int(month)
        myDateComponents.day = Int(day)
        myDateComponents.hour = Int(hour)
        myDateComponents.minute = Int(minute)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: myDateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: " Identifier", content: content, trigger: trigger)
        
        // 通知を登録
        center.add(request) { (error : Error?) in
            if error != nil {
                // エラー処理
            }
        }
        tt.text = "通知設定時刻: " + text
        
    }
    
    @IBOutlet weak var picker: UIDatePicker!
    
    @IBOutlet weak var closebtn: UIButton!
    
    // グーグルマップの設定をする変数
    var googleMap : GMSMapView!
    
    //緯度経度 -> 足利市駅
    var latitude2: CLLocationDegrees = 36.32913
    var longitude2: CLLocationDegrees = 139.44827
    
    let latitude: CLLocationDegrees = 35.681541
    let longitude: CLLocationDegrees = 139.767136
    
    let marker: GMSMarker = GMSMarker()
    
    // 位置情報取得のための変数
    var locationManager: CLLocationManager!
    //@IBOutlet weak var 取得時刻: UILabel!
    
    // 起動時に実行される関数
    override func viewDidLoad() {
        // スーパークラス
        super.viewDidLoad()
        
        // インスタンスの生成
        locationManager = CLLocationManager()
        // CLLocationManagerDelegateプロトコルを実装するクラスを指定する
        locationManager.delegate = self
        

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
        // 表示テスト用の乱数を生成
        initialText1 = point1 //経度用
        initialText2 = point2 //緯度用
        
        // DocumentディレクトリのfileURLを取得
        if let documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
            // ディレクトリのパスにファイル名をつなげてファイルのフルパスを作る
            let targetTextFilePath1 = documentDirectoryFileURL.appendingPathComponent(textFileName1) //経度用
            let targetTextFilePath2 = documentDirectoryFileURL.appendingPathComponent(textFileName2) //緯度用
            //  テキストファイルを作成
            do {
                try initialText1.write(to: targetTextFilePath1, atomically: true, encoding: String.Encoding.utf8) //経度を書き込み（上書き）
                try initialText2.write(to: targetTextFilePath2, atomically: true, encoding: String.Encoding.utf8) //緯度を書き込み（上書き）
                //  テキストファイルを読み込む（デバッグ用）
                do {
                    contents1 = try String(contentsOf: targetTextFilePath1, encoding: String.Encoding.utf8) //経度用のテキストファイルから経度を読み取る
                    contents2 = try String(contentsOf: targetTextFilePath2, encoding: String.Encoding.utf8) //緯度用のテキストファイルから緯度を読み取る
                } catch let error as NSError {
                    print("failed to read: \(error)") //例外処理
                }
            } catch let error as NSError {
                print("failed to write: \(error)") //例外処理
            }
        }
    }
    
    //  「位置を表示」ボタンに対応
    @IBAction func hyouzi(_ sender: Any) {
        content.text = "経度：" + contents1 //経度を表示
        content2.text = "経度：" + contents2 //緯度を表示
    }
    
    //  「リセット」ボタンに対応
    @IBAction func reset(_ sender: Any) {
        initialText1 = "999.0000" //初期化テキスト
        initialText2 = "999.0000" //初期化テキスト
        // DocumentディレクトリのfileURLを取得
        if let documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last {
            // ディレクトリのパスにファイル名をつなげてファイルのフルパスを作る
            let targetTextFilePath1 = documentDirectoryFileURL.appendingPathComponent(textFileName1) //経度用
            let targetTextFilePath2 = documentDirectoryFileURL.appendingPathComponent(textFileName2) //緯度用
            //  テキストファイルを作成
            do {
                try initialText1.write(to: targetTextFilePath1, atomically: true, encoding: String.Encoding.utf8) //経度を書き込み（上書き）
                try initialText2.write(to: targetTextFilePath2, atomically: true, encoding: String.Encoding.utf8) //緯度を書き込み（上書き）
                //  テキストファイルを読み込む
                do {
                    contents1 = try String(contentsOf: targetTextFilePath1, encoding: String.Encoding.utf8) //経度用のテキストファイルから経度を読み取る
                    contents2 = try String(contentsOf: targetTextFilePath2, encoding: String.Encoding.utf8) //緯度用のテキストファイルから緯度を読み取る
                } catch let error as NSError {
                    print("failed to read: \(error)") //例外処理
                }
            } catch let error as NSError {
                print("failed to write: \(error)") //例外処理
            }
        }
    }
    
    @IBAction func review(_ sender: Any) {
        if atof(contents1) != 999 {
            //まずは、同じstororyboard内であることをここで定義します
            let storyboard: UIStoryboard = self.storyboard!
            //ここで移動先のstoryboardを選択(今回の場合は先ほどsecondと名付けたのでそれを書きます)
            let second = storyboard.instantiateViewController(withIdentifier: "map")
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
    
}

// 位置情報取得のための
extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("ユーザーはこのアプリケーションに関してまだ選択を行っていません")
            locationManager.requestWhenInUseAuthorization()
            break
        case .denied:
            print("ローケーションサービスの設定が「無効」になっています (ユーザーによって、明示的に拒否されています）")
            // 「設定 > プライバシー > 位置情報サービス で、位置情報サービスの利用を許可して下さい」を表示する
            break
        case .restricted:
            print("このアプリケーションは位置情報サービスを使用できません(ユーザによって拒否されたわけではありません)")
            // 「このアプリは、位置情報を取得できないために、正常に動作できません」を表示する
            break
        case .authorizedAlways:
            print("常時、位置情報の取得が許可されています。")
            // 位置情報取得の開始処理
            break
        case .authorizedWhenInUse:
            print("起動時のみ、位置情報の取得が許可されています。")
            // 位置情報取得の開始処理
            locationManager.startUpdatingLocation()
            break
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        for location in locations {
            point1 = "\(location.coordinate.latitude)"
            point2 = "\(location.coordinate.longitude)"
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("位置情報の取得に失敗しました")
    }
    
    // 画面遷移
    @IBAction func back(segue: UIStoryboardSegue) {
        
    }
    
    
}

