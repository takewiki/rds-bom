


# 1.00  shinyUI start point----

shinyUI(dashboardPage(skin = "blue",
                    
                
                    
                    dashboardHeader(title = app_title,
                                    tags$li(class = "dropdown", style = "padding: 8px;",
                                            uiOutput('show_user')),
                                    
                                    tags$li(class = "dropdown", style = "padding: 8px;",
                                            shinyauthr::logoutUI("logout",label = '注销')),
                                   
                                    #headerMsg1,
                                    #dynamicMsgMenu,
                                   # NotiMenuObj,
                                    disable = F
                    ),
                    
                    #ui.sideBar----
                    dashboardSidebar(
                    
                       #sidebarMenu
                       uiOutput('show_sidebarMenu')
                    ),
                    
                    #ui.body----
                    dashboardBody(
                      shinyjs::useShinyjs(),
                      use_pop(),
                      tags$head(tags$style(".table{margin: 0 auto;}"),
                                tags$script(src="https://cdnjs.cloudflare.com/ajax/libs/iframe-resizer/3.5.16/iframeResizer.contentWindow.min.js",
                                            type="text/javascript"),
                                includeScript("returnClick.js")
                      ),
                      shinyauthr::loginUI("login",title = '登录界面',user_title = '用户名',pass_title = '密码',login_title = '登录',error_message = '用户名或密码错误,请重试！'),
                      uiOutput('show_workAreaSetting'),
                      HTML('<div data-iframe-height></div>')
                    )
)
)


