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

// グローバル変数集
let textFileName1 = "xpoint.txt" //経度記憶用のテキストファイル名
let textFileName2 = "ypoint.txt" //緯度記憶用のテキストファイル名
var initialText1 = String("000.0000") //初期テキスト
var initialText2 = String("000.0000") //初期テキスト
var contents1 = String("テスト\n用\nテキスト1") //経度表示用のグローバル変数
var contents2 = String("テスト\n用\nテキスト2") //緯度表示用のグローバル変数

class ViewController: UIViewController {
    
    // 位置情報取得のための変数
    var locationManager: CLLocationManager!
    
    //
    @IBOutlet weak var 緯度: UILabel!
    @IBOutlet weak var 経度: UILabel!
    @IBOutlet weak var 取得時刻: UILabel!
    
    
    // 起動時に実行される関数
    override func viewDidLoad() {
        // スーパークラス
        super.viewDidLoad()
        
        // インスタンスの生成
        locationManager = CLLocationManager()
        // CLLocationManagerDelegateプロトコルを実装するクラスを指定する
        locationManager.delegate = self
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
            緯度.text = "緯度:\(location.coordinate.latitude)"
            経度.text = "経度:\(location.coordinate.longitude)"
            取得時刻.text = "取得時刻:\(location.timestamp.description)"
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("位置情報の取得に失敗しました")
    }
}
