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

class ViewControllerA: UIViewController {
    // グーグルマップの設定をする変数
    var googleMap : GMSMapView!
    let latitude: CLLocationDegrees = 35.681541
    let longitude: CLLocationDegrees = 139.767136
    let marker: GMSMarker = GMSMarker()
    
    override func viewDidLoad() {
        // スーパークラス
        super.viewDidLoad()
        // ズームレベル.
        let zoom: Float = 15
        
        // カメラを生成.
        let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: latitude,longitude: longitude, zoom: zoom)
        
        // MapViewを生成.
        googleMap = GMSMapView(frame: CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height/2))
        googleMap.tag = 10
        
        googleMap.isMyLocationEnabled = true
        
        // MapViewの現在地ボタンを有効にする.
        googleMap.settings.myLocationButton = true
        
        // MapViewにカメラを追加.
        googleMap.camera = camera
        
        //マーカーの作成
        marker.position = CLLocationCoordinate2DMake(latitude, longitude)
        marker.title = "東武足利市駅"
        marker.map = googleMap
        self.view.addSubview(googleMap)
        
        // 端末回転の通知機能を設定します。
        let action = #selector(orientationDidChange(_:))
        let center = NotificationCenter.default
        let name = UIDevice.orientationDidChangeNotification
        center.addObserver(self, selector: action, name: name, object: nil)
        
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
        
        let latitudex = atof(contents1)
        let longitudey = atof(contents2)
        marker.position = CLLocationCoordinate2DMake(latitudex, longitudey)
        let camera2: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: latitudex,longitude: longitudey, zoom: 17.5)
        googleMap.camera = camera2
        
    }
    
    @objc func orientationDidChange(_ notification: NSNotification) {
        // 端末の向きを判定します。
        // 縦向きを検知する場合、
        //   device.orientation.isPortrait
        // を判定します。
        let device = UIDevice.current
        let latitudex = atof(contents1)
        let longitudey = atof(contents2)
        if device.orientation.isLandscape {
            if let viewWithTag = self.view.viewWithTag(10) {
                viewWithTag.removeFromSuperview()
            }
            googleMap = GMSMapView(frame: CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height))
            googleMap.tag = 10
            googleMap.isMyLocationEnabled = true
            // MapViewの現在地ボタンを有効にする.
            googleMap.settings.myLocationButton = true
            // ズームレベル.
            let zoom: Float = 18
            // MapViewにカメラを追加.
            let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: latitudex,longitude: longitudey, zoom: zoom)
            googleMap.camera = camera
            //マーカーの作成
            marker.position = CLLocationCoordinate2DMake(latitudex, longitudey)
            marker.title = "東武足利市駅"
            marker.map = googleMap
            self.view.addSubview(googleMap)
        } else {
            if let viewWithTag = self.view.viewWithTag(10) {
                viewWithTag.removeFromSuperview()
            }
            // ズームレベル.
            let zoom: Float = 15
            
            // カメラを生成.
            let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: latitudex,longitude: longitudey, zoom: zoom)
            
            // MapViewを生成.
            googleMap = GMSMapView(frame: CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height/2))
            googleMap.tag = 10
            
            googleMap.isMyLocationEnabled = true
            
            // MapViewの現在地ボタンを有効にする.
            googleMap.settings.myLocationButton = true
            
            // MapViewにカメラを追加.
            googleMap.camera = camera
            
            //マーカーの作成
            marker.position = CLLocationCoordinate2DMake(latitudex, longitudey)
            marker.title = "東武足利市駅"
            marker.map = googleMap
            self.view.addSubview(googleMap)
        }
    }
    
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
}

class ViewController: UIViewController {
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
        
      
        var myDateComponents = DateComponents()
        
        myDateComponents.year = 2019
        myDateComponents.month = 8
        myDateComponents.day = 5
        myDateComponents.hour = 16
        myDateComponents.minute = 19
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: myDateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: " Identifier", content: content, trigger: trigger)
        
        // 通知を登録
        center.add(request) { (error : Error?) in
            if error != nil {
                // エラー処理
            }
        }

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
    
    
}

