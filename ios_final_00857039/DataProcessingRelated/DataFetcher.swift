//
//  GetData.swift
//  ios_final_00857039
//
//  Created by User20 on 2022/12/17.
//

import SwiftUI
import CryptoKit

class DataFetcher: ObservableObject {
    
    @AppStorage("TDXAccessToken") var TDXAccessTokenStorage: String = ""
    @AppStorage("trainStationInformationDataItems") var trainStationInformationDataItemsStorage: Data?
    
    //指定起迄站資料
    @Published var originDestinationTrainDataItems = [OriginDestinationTrainData]()
    
    //台鐵所有車站詳細資料
    @Published var trainStationInformationDataItems = [TrainStationInformationData](){
        didSet{
            let encoder = JSONEncoder()
            do {
                trainStationInformationDataItemsStorage = try encoder.encode(trainStationInformationDataItems)
            } catch {
                print(error)
            }
        }
    }
    //天氣資料
    @Published var TargetCityCurrentWhether = [CityCurrentWeatherData]()
    
    //指定車次時間表
    @Published var timeTableOfTargetTrainNumber = [TimeTableOfTrainNumberData]()
    
    //資料獲取與抓取資料錯誤相關
    @Published var isGettingOriginToDestinationStationTrain:Bool = false
    @Published var isGettingTimeTableFromTrainNumber:Bool = false
    @Published var showError = false
    var error: Error? {
        willSet {
            DispatchQueue.main.async {
                self.showError = newValue != nil
            }
        }
    }
    
    //調用tdx api資料前的認證動作
    func getAccessToken(whichFunctionCall:String,originStationID:String = "1000" ,destinationStationID:String = "4400",inquiryDate:String = "2022-01-01",departureTime:String = "00:00",TrainNo:String = "115"){
        //originStationID:String,destinationStationID:String用於重新呼叫getOriginToDestinationStationTrain函式
        print("訊息：get access token...")
        guard let url = URL(string: AccessTokenUrl) else{
            self.error = FetchError.invalidURL
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "post"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
        let data = "grant_type=client_credentials&client_id=\(clientId)&client_secret=\(clientSecret)".data(using: .utf8)
        request.httpBody = data
        let decoder = JSONDecoder()
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data=data {
                do {
                    let accessTokenString = try decoder.decode(accessTokenJSONData.self, from: data)
                    if let pp = accessTokenString.access_token{
                        self.TDXAccessTokenStorage = pp
                        switch whichFunctionCall{
                        case "getTrainStationID":
                            self.getTrainStationID()
                        case "getOriginToDestinationStationTrain":
                            self.getOriginToDestinationStationTrain(originStationID: originStationID, destinationStationID: destinationStationID,inquiryDate:inquiryDate,departureTime: departureTime)
                        case "getTimeTableFromTrainNumber":
                            self.getTimeTableFromTrainNumber(TrainNo: TrainNo, inquiryDate: inquiryDate)
                        default:
                            return
                        }
                    }
                   
                } catch {
                    print(error)
                    self.error = FetchError.invalidData
                    
                }
            } else if let error=error {
                print(error)
                self.error = FetchError.offline
            }
        }.resume()
    }
    
    //取得台鐵所有車站代碼
    func getTrainStationID(){
        print("訊息：getTrainStationID...")
        guard let url = URL(string: "https://tdx.transportdata.tw/api/basic/v2/Rail/TRA/Station?%24format=JSON")else{
            self.error = FetchError.invalidURL
            return
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(TDXAccessTokenStorage)", forHTTPHeaderField: "authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data=data {
                let statusCode = (response as? HTTPURLResponse)?.statusCode
                if statusCode == 401 {
                    print("\n訊息：regain access token...\n")
                    self.getAccessToken(whichFunctionCall: "getTrainStationID")
                } else {
                    //print(String(data: data, encoding: .utf8)!)
                    let decoder = JSONDecoder()
                    do {
                        let dataItems = try decoder.decode([TrainStationInformationData].self, from: data)
                        DispatchQueue.main.async {
                            self.trainStationInformationDataItems = dataItems.filter {
                                $0.StationName.Zh_tw != "臺北-環島"
                            }
                            self.error = nil
                        }
                        //print(trainStationID)
                        /*trainStationID.filter {
                         $0.StationName.Zh_tw.contains("南")
                         }.forEach{item in print(item.StationName.Zh_tw)}
                         //print(rr[0].StationID,rr[0].StationName.Zh_tw)*/
                    } catch {
                        print(error)
                        self.error = FetchError.invalidData
                    }
                }
            } else if let error=error {
                print(error)
                self.error = FetchError.offline
            }
        }.resume()
        
    }
    
    //取得指定起迄站間的所有列車資訊
    func getOriginToDestinationStationTrain(originStationID:String = "1000" ,destinationStationID:String = "4400",inquiryDate:String = "2022-01-01",departureTime:String = "00:00") { //預設查詢台北到高雄出發時間為2022-1-1 00:00的臺鐵班次
        print("     呼叫func：getOriginToDestinationStationTrain {")
        print("              OriginStationID: \(originStationID)")
        print("              destinationStationID: \(destinationStationID)")
        print("              inquiryDate: \(inquiryDate)\n          }")
        let split = departureTime.components(separatedBy: ":")
        let hourOfDepartureTime:String = split[0]
        let minuteOfDepartureTime:String = split[1]
        
        /*odata quiry with no $filter(測試用）
         https://tdx.transportdata.tw/api/basic/v2/Rail/TRA/DailyTimetable/OD/\(originStationID)/to/\(destinationStationID)/\(inquiryDate)?%24orderby=OriginStopTime%2FDepartureTime&%24format=JSON
         */
        /*odata quiry with $filter
         https://tdx.transportdata.tw/api/basic/v2/Rail/TRA/DailyTimetable/OD/\(originStationID)/to/\(destinationStationID)/\(inquiryDate)?%24filter=OriginStopTime%2FDepartureTime%20ge%20%27\(hourOfDepartureTime)%3A\(minuteOfDepartureTime)%27&%24orderby=OriginStopTime%2FDepartureTime&%24format=JSON
         */
        guard let url = URL(string: "https://tdx.transportdata.tw/api/basic/v2/Rail/TRA/DailyTimetable/OD/\(originStationID)/to/\(destinationStationID)/\(inquiryDate)?%24filter=OriginStopTime%2FDepartureTime%20ge%20%27\(hourOfDepartureTime)%3A\(minuteOfDepartureTime)%27&%24orderby=OriginStopTime%2FDepartureTime&%24format=JSON") else{
            self.error = FetchError.invalidURL
            self.isGettingOriginToDestinationStationTrain = false
            return
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(TDXAccessTokenStorage)", forHTTPHeaderField: "authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data=data {
                let statusCode = (response as? HTTPURLResponse)?.statusCode
                if statusCode == 401 {//重新取得有效的access token
                    print("\n訊息：regain access token...\n")
                    self.getAccessToken(whichFunctionCall: "getOriginToDestinationStationTrain",originStationID: originStationID,destinationStationID: destinationStationID,inquiryDate: inquiryDate,departureTime: departureTime)
                } else {
                    //print(String(data: data, encoding: .utf8)!)
                    if(String(data: data, encoding: .utf8)! == "{\"Message\":\"TrainDate: 無提供此歷史資料\"}"){//dayAboutTRAInquiry過期了,自動更新成今天再查詢一次
                        let now = Date()
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        print("訊息：查詢之日期已更新")
                        self.getOriginToDestinationStationTrain(originStationID: originStationID,destinationStationID: destinationStationID,inquiryDate: dateFormatter.string(from: now),departureTime: departureTime)
                    }
                    else{//dayAboutTRAInquiry沒過期,直接查詢
                        let decoder = JSONDecoder()
                        do {
                            let dataItems = try decoder.decode([OriginDestinationTrainData].self, from: data)
                            //print(String(data: data, encoding: .utf8))
                            DispatchQueue.main.async {
                                self.originDestinationTrainDataItems = dataItems
                                self.isGettingOriginToDestinationStationTrain = false
                                self.error = nil
                            }
                            /*self.originDestinationTrainDataItems.forEach{item in
                             print("車號:\(item.DailyTrainInfo.TrainNo)\n起點：\(item.DailyTrainInfo.StartingStationName.En)\n終點：\(item.DailyTrainInfo.EndingStationName.En)\n車種ID：\(item.DailyTrainInfo.TrainTypeID)\n備註：\(item.DailyTrainInfo.Note.Zh_tw)\n時間：\(item.OriginStopTime.DepartureTime)～\(item.DestinationStopTime.DepartureTime)\n\n")
                             }*/
                        } catch {
                            print("eeeeee")
                            print(error)
                            DispatchQueue.main.async {
                                self.isGettingOriginToDestinationStationTrain = false
                            }
                            self.error = FetchError.invalidData
                            return
                        }
                    }
                }
            } else if let error=error {
                print(error)
                self.error = FetchError.offline
                DispatchQueue.main.async {
                    self.isGettingOriginToDestinationStationTrain = false
                }
            }
        }.resume()
    }
    
    //取得指定台鐵車次的時間表
    func getTimeTableFromTrainNumber(TrainNo:String = "115",inquiryDate:String = "2022-01-01"){
        print("訊息：getTimeTableFromTrainNumber...")
        guard let url = URL(string: "https://tdx.transportdata.tw/api/basic/v2/Rail/TRA/DailyTimetable/TrainNo/\(TrainNo)/TrainDate/\(inquiryDate)?%24format=JSON")else{
            self.error = FetchError.invalidURL
            return
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(TDXAccessTokenStorage)", forHTTPHeaderField: "authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data=data {
                let statusCode = (response as? HTTPURLResponse)?.statusCode
                if statusCode == 401 {
                    print("\n訊息：regain access token...\n")
                    self.getAccessToken(whichFunctionCall: "getTimeTableFromTrainNumber",inquiryDate:inquiryDate,TrainNo:TrainNo)
                }else if String(data: data, encoding: .utf8)! == "\"Message\": \"TrainDate: 無提供此歷史資料\""{
                    let now = Date()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    print("訊息：查詢之日期已更新")
                    self.getTimeTableFromTrainNumber(TrainNo: TrainNo, inquiryDate: dateFormatter.string(from: now))
                }else {
                    //print(String(data: data, encoding: .utf8)!)
                    let decoder = JSONDecoder()
                    do {
                        let dataItems = try decoder.decode([TimeTableOfTrainNumberData].self, from: data)
                        DispatchQueue.main.async {
                            self.timeTableOfTargetTrainNumber = dataItems
                            self.error = nil
                            print("成功取得車次：\(TrainNo) 日期：\(inquiryDate)之時間表！")
                        }
                    } catch {
                        print(error)
                        self.error = FetchError.invalidData
                    }
                }
            } else if let error=error {
                print(error)
                self.error = FetchError.offline
            }
        }.resume()
    }
    
    //取得指定城市的目前天氣
    func getCityCurrentWhether(cityName_TW:String = "臺北市"){
        
        
        let someDict:[String:String] = ["基隆市":"Keelung", "臺北市":"Taipei" , "新北市":"New%20Taipei", "桃園市":"Taoyuan%20City", "新竹縣":"Hsinchu" ,
                                        "新竹市":"Hsinchu", "苗栗縣":"Miaoli" , "臺中市":"Taichung"    , "彰化縣":"Changhua"      , "雲林縣":"Yunlin"  ,
                                        "嘉義縣":"Chiayi" , "嘉義市":"Chiayi" , "臺南市":"Tainan"      , "高雄市":"Kaohsiung"     , "屏東縣":"Pingtung",
                                        "臺東縣":"Taitung", "花蓮縣":"Hualien", "宜蘭縣":"Yilan"       , "南投縣":"Nantou"        , "澎湖縣":"Penghu"  ,
                                        "金門縣":"Kinmen" , "連江縣":"Lianjiang"]
        var cityName_EN = "Taipei"
        if let cityName = someDict[cityName_TW]{
            cityName_EN = cityName
        }
        //get location and then get whether
        guard let url = URL(string: "https://api.openweathermap.org/geo/1.0/direct?q=\(cityName_EN),TW&limit=1&appid=4d26ccd4216d2da38e4f05615d66d13b")else{
            print("錯誤網址")
            self.error = FetchError.invalidURL
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data=data {
                let decoder = JSONDecoder()
                do {
                    let dataItems = try decoder.decode([CityLatitudeAndLongitudeLocationData].self, from: data)
                    if dataItems.count == 0{
                        print("找不到城市！")
                        return
                    }else{
                        for item in dataItems{
                            print("查詢 \(dataItems[0].local_names.zh) 天氣")
                            let lat = item.lat
                            let lon = item.lon
                            guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&units=metric&appid=4d26ccd4216d2da38e4f05615d66d13b&lang=zh_tw")else{
                                self.error = FetchError.invalidURL
                                return
                            }
                            URLSession.shared.dataTask(with: url) { data, response, error in
                                if let data=data {
                                    let decoder = JSONDecoder()
                                    do {
                                        let dataItem = try decoder.decode(CityCurrentWeatherData.self, from: data)
                                        DispatchQueue.main.async {
                                            self.TargetCityCurrentWhether.removeAll()
                                            self.TargetCityCurrentWhether.append(dataItem)
                                            self.error = nil
                                            //print(self.TargetCityCurrentWhether.count)
                                            //print("體感溫度：\(self.TargetCityCurrentWhether[0].main.feels_like)")
                                            //print("icon：\(self.TargetCityCurrentWhether[0].weather[0].icon)")
                                        }
                                        return
                                    } catch {
                                        print(error)
                                        self.error = FetchError.invalidData
                                    }
                                } else if let error=error {
                                    print(error)
                                    self.error = FetchError.offline
                                }
                            }.resume()
                            return
                        }
                    }
                   
                }catch {
                    print(error)
                    self.error = FetchError.invalidData
                }
                
            } else if let error=error {
                print(error)
                self.error = FetchError.offline
            }
        }.resume()
    }
}

