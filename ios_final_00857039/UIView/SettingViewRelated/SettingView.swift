//
//  SettingView.swift
//  ios_final_00857039
//
//  Created by User04 on 2022/12/27.
//

import SwiftUI
//import SwiftClockUI
//import SnapshotTesting


struct SettingView: View {
    
    @EnvironmentObject var saver: DataSaver
    
    @State private var showShareSheet = false
    @State private var showChooseThemeColorView = false
    @State private var showLogOutAlert = false
    
    @Binding var mainViewBarColor: Color
    
    //登出相關
    @Binding var logInUserAccountMessage:String
    @Binding var logInPasswordMessage:String
    @Binding var userAccountLoginInput:String
    @Binding var passwordLoginInput:String
    @Binding var viewMode:Int
    
    func LogOut(){
        logInUserAccountMessage  = ""
        logInPasswordMessage = ""
        userAccountLoginInput = ""
        passwordLoginInput = ""
        saver.UserData.removeAll()
        viewMode = 2
    }
    var body: some View {
        ZStack{
            VStack{
                VStack(alignment: .leading){
                    Text("畫面設定")
                        .padding(.top,15)
                    NavigationLink(
                        destination: ChooseThemeColorView(mainViewBarColor: $mainViewBarColor),
                        label: {
                            FunctionRow(icon:"paintpalette.fill",iconColor:Color.orange,title:"改變顏色",description:"更改App的主題顏色")
                        })
                    /*Button{
                     showChooseThemeColorView = true
                     }label:{
                     FunctionRow(icon:"paintpalette.fill",iconColor:Color.orange,title:"改變顏色",description:"更改App的主題顏色")
                     .sheet(isPresented: $showChooseThemeColorView){
                     ChooseThemeColorView(show: $showChooseThemeColorView, mainViewBarColor: $mainViewBarColor)
                     }
                     }*/
                    Divider()
                        .overlay(Color.primary)
                    Text("通知")
                    HStack{
                        Image(systemName:"exclamationmark.triangle")
                            .resizable()
                            .scaledToFit()
                            .frame(width:40,height:40)
                            .foregroundColor(Color.secondary)
                        VStack(alignment:.leading){
                            Text("施工中...")
                                .font(.custom(fontStyle, size: 24))
                                .foregroundColor(.secondary)
                            Text("工程師正在努力開發中")
                                .font(.custom(fontStyle, size: 14))
                                .foregroundColor(.secondary)
                        }
                    }
                    Divider()
                        .overlay(Color.primary)
                    Text("其他")
                    Button{
                        showShareSheet = true
                    }label:{
                        FunctionRow(icon:"square.and.arrow.up",iconColor:Color.green,title:"分享這個App",description:"讓更多朋友知道這個App吧")
                            .sheet(isPresented: $showShareSheet) {
                                ShareView()
                            }
                        
                    }
                    NavigationLink(
                        destination:LearnMoreFromWebView(),
                        label: {
                            FunctionRow(icon:"questionmark",iconColor:Color.blue,title:"了解更多",description:"了解本App的相關功能介紹")
                        })
                 
                    /*Link(destination: URL(string: "https://medium.com/@wys899195/4%E6%9C%9F%E6%9C%AB%E5%B0%88%E6%A1%88-%E5%8F%B0%E9%90%B5%E6%9F%A5%E8%A9%A2app-b57222e1ade")!, label: {
                        FunctionRow(icon:"questionmark",iconColor:Color.blue,title:"了解更多",description:"了解本App的相關功能介紹")
                    })*/
                    //ClockView().environment(\.clockStyle, .classic)
                }.padding(.horizontal,20)
                //.background(Color.primary)
                
                VStack(alignment: .center){
                    Button{
                        showLogOutAlert = true
                    }label:{
                        Label("登出" ,systemImage:"power")
                            .font(.custom(fontStyle, size: 16))
                            .frame(width: UIScreen.main.bounds.width/10*8, height: 40)
                            .background(themeColors_Item[saver.ThemeColorID])
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .alert(isPresented: $showLogOutAlert, content: {
                        Alert(title: Text("確定要登出嗎？"),
                              primaryButton:
                                .default(Text("取消")),
                              secondaryButton:
                                .destructive(Text("登出"), action: {
                                    LogOut()
                                }))
                    })
                }.padding(.top,15)
                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: {
            ToolbarItem(placement: .principal) {
                HStack{
                    Text("設定")
                        .font(.custom(fontStyle, size: 20))
                    
                }
            }
        })
        //.edgesIgnoringSafeArea(.top)
    }
}


