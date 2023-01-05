//
//  MainView.swift
//  ios_final_00857039
//
//  Created by User04 on 2023/1/2.

//參考網址
//1.動態改變navigationbar:
//  https://stackoverflow.com/questions/69262266/dynamically-change-and-update-color-of-navigation-bar-in-swiftui
//2.Binding變數初始化：
//  https://reurl.cc/WqYNyy
//3.State變數初始化：
//  https://stackoverflow.com/questions/56691630/swiftui-state-var-initialization-issue

import SwiftUI
import Kingfisher

struct MainView:View{
    
    @EnvironmentObject var saver: DataSaver
    @EnvironmentObject var fetcher: DataFetcher
    
    @Binding var showLogInSuccessAlert:Bool
    
    @State var navigationBarColor:Color
    
    @Binding var logInUserAccountMessage:String
    @Binding var logInPasswordMessage:String
    @Binding var userAccountLoginInput:String
    @Binding var passwordLoginInput:String
    @Binding var viewMode:Int
    
    @State private var showWeatherLocationSelectView: Bool
    @State private var today:String
    @State private var weatherLocationCity:String
    
    init(showLogInSuccessAlert:Binding<Bool>,logInUserAccountMessage:Binding<String>,logInPasswordMessage:Binding<String>,userAccountLoginInput:Binding<String>,passwordLoginInput:Binding<String>,viewMode:Binding<Int>,barColor: Color) {
        
        self._navigationBarColor = State(initialValue: Color.red)
        
        self._showLogInSuccessAlert = showLogInSuccessAlert
        self._logInUserAccountMessage = logInUserAccountMessage
        self._logInPasswordMessage = logInPasswordMessage
        self._userAccountLoginInput = userAccountLoginInput
        self._passwordLoginInput = passwordLoginInput
        self._viewMode = viewMode
        
        self._showWeatherLocationSelectView = State(initialValue:false)
        self._weatherLocationCity = State(initialValue: "")
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        self._today = State(initialValue: dateFormatter.string(from: now))
       

        let navbarAppearance = UINavigationBarAppearance()
        navbarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navbarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navbarAppearance.backgroundColor = UIColor(barColor)
        UINavigationBar.appearance().standardAppearance = navbarAppearance
        UINavigationBar.appearance().compactAppearance = navbarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navbarAppearance
        UINavigationBar.appearance().tintColor = .black
    }
    
    var body: some View {
        NavigationView{
            ZStack{
                themeColors_BackGround[saver.ThemeColorID]
                VStack{
                    
                    HStack(alignment: .bottom){
                        VStack(alignment:.leading){
                            Text(saver.weatherLocationCity)
                                .font(.custom(fontStyle, size: 28))
                                .foregroundColor(.primary)
                            HStack{
                                Text(today)
                                    .font(.custom(fontStyle, size: 16))
                                if(fetcher.TargetCityCurrentWhether.count == 1){
                                    Text(fetcher.TargetCityCurrentWhether[0].weather[0].description)
                                        .font(.custom(fontStyle, size: 16))
                                }else{
                                    Text("讀取中...")
                                        .font(.custom(fontStyle, size: 16))
                                }
                            }
                            
                        }
                        Spacer()
                        Button{
                            fetcher.TargetCityCurrentWhether.removeAll()
                            fetcher.getCityCurrentWhether(cityName_TW:saver.weatherLocationCity)
                        }label:{
                            Image(systemName: "arrow.clockwise")
                                .frame(width: 40, height: 40)
                                .background(themeColors_Item[saver.ThemeColorID])
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }.padding(EdgeInsets(top: 5, leading: 5, bottom: -20, trailing: 5))
                    HStack{
                        if(fetcher.TargetCityCurrentWhether.count == 1){
                            let iconURL = "https://openweathermap.org/img/wn/\(fetcher.TargetCityCurrentWhether[0].weather[0].icon)@4x.png"
                            KFImage(URL(string: iconURL))
                                .placeholder({
                                    KFImage(URL(string: iconURL))
                                })
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .padding(EdgeInsets(top: 0, leading: -15, bottom:  0, trailing: -15))
                            VStack{
                                Text("\(String(format: "%.0f", fetcher.TargetCityCurrentWhether[0].main.temp))")
                                    .font(.custom(fontStyle, size: 50)) + Text("°C")
                                    .font(.custom(fontStyle, size: 16))
                                HStack{
                                    Text("▲\(String(format: "%.0f", fetcher.TargetCityCurrentWhether[0].main.temp_max))°C")
                                        .font(.custom(fontStyle, size: 12))
                                    Text("▼\(String(format: "%.0f", fetcher.TargetCityCurrentWhether[0].main.temp_min))°C")
                                        .font(.custom(fontStyle, size: 12))
                                }
                            }.padding(.trailing,30)
                        }else{
                            ProgressView()
                                .frame(width: 100, height: 107)
                                .scaleEffect(x: 2, y: 2)
                            //.padding(EdgeInsets(top: 0, leading: -15, bottom:  0, trailing: -15))
                        }
                        
                        
                        
                    }
                    HStack{
                        if(fetcher.TargetCityCurrentWhether.count == 1){
                            Text("體感溫度：\(String(format: "%.0f", fetcher.TargetCityCurrentWhether[0].main.feels_like))°C")
                                .font(.custom(fontStyle, size: 14))
                            Text("濕度：\(String(format: "%.0f", fetcher.TargetCityCurrentWhether[0].main.humidity))%")
                                .font(.custom(fontStyle, size: 14))
                        }else{
                            Text("體感溫度：讀取中...")
                                .font(.custom(fontStyle, size: 14))
                            Text("濕度：讀取中...")
                                .font(.custom(fontStyle, size: 14))
                        }
                    }.padding(.vertical,-10)
                    HStack{
                        Button{
                            showWeatherLocationSelectView = true
                            
                        }label:{
                            Label("更換地區",systemImage:"mappin.and.ellipse")
                                .font(.custom(fontStyle, size: 16))
                                .frame(width: UIScreen.main.bounds.width/10*8, height: 40)
                                .background(themeColors_Item[saver.ThemeColorID])
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .sheet(isPresented: $showWeatherLocationSelectView){
                                    WeatherLocationSelectView(show: $showWeatherLocationSelectView )
                                }
                        }
                    }
                    .padding(EdgeInsets(top: 4, leading: 0, bottom: 0, trailing: 0))
                    List{
                        NavigationLink(
                            destination: TRAInquiryMainView(),
                            label: {
                                FunctionRow(icon:"tram.fill",iconColor:Color.blue,title:"台鐵查詢",description:"查詢台灣各列車的時刻表")
                            })
                        NavigationLink(
                            destination: MyFavoriteRouteView(),
                            label: {
                                FunctionRow(icon:"heart.fill",iconColor:Color.red,title:"最愛路線",description:"收藏常用路線以便快速查詢")
                            })
                        NavigationLink(
                            destination: SettingView(mainViewBarColor: $navigationBarColor, logInUserAccountMessage: $logInUserAccountMessage, logInPasswordMessage: $logInPasswordMessage, userAccountLoginInput: $userAccountLoginInput, passwordLoginInput: $passwordLoginInput, viewMode: $viewMode),
                            label: {
                                FunctionRow(icon:"gearshape.fill",iconColor:Color.gray,title:"其他功能",description:"一些其他的功能在這裡")
                            })
                    
                        
                    }
                    
                }
                
                
                
            }
            .alert(isPresented: $showLogInSuccessAlert) {
                Alert(title: Text("登入成功！"),
                      dismissButton: .default(Text("關閉")))
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: {
                if(fetcher.TargetCityCurrentWhether.isEmpty){
                    fetcher.getCityCurrentWhether(cityName_TW:saver.weatherLocationCity)
                }
                if(fetcher.trainStationInformationDataItems.isEmpty){
                    fetcher.getTrainStationID()
                }
                self.navigationBarColor = themeColors_BackGround[saver.ThemeColorID]
            })
            .onChange(of: saver.weatherLocationCity, perform: {value in
                fetcher.TargetCityCurrentWhether.removeAll()
                fetcher.getCityCurrentWhether(cityName_TW:saver.weatherLocationCity)
            })

            .toolbar(content: {
                ToolbarItem(placement: .principal) {
                    Text("台鐵查詢App")
                        .font(.custom(fontStyle, size: 20))
                }
            })
          
        }
    }
}
