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
var point1 = String("point1")
var point2 = String("point2")



class ViewController: UIViewController {
    
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
    
    //  「位置を表示」ボタンに対応
    @IBAction func hyouzi(_ sender: Any) {
        content.text = "経度：" + contents1 //経度を表示
        content2.text = "経度：" + contents2 //緯度を表示
    }
    
    //  「リセット」ボタンに対応
    @IBAction func reset(_ sender: Any) {
        initialText1 = "000.0000" //初期化テキスト
        initialText2 = "000.0000" //初期化テキスト
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
        content.text = "経度：" + contents1 //経度を表示
        content2.text = "経度：" + contents2 //緯度を表示
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
