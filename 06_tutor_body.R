menu_tutor <- tabItem(tabName = "tutor",
                      fluidRow(
                        column(width = 12,
                               tabBox(title ="用户工作台",width = 12,
                                      id='tabSetUsrMngr',height = '300px',
                                      tabPanel('批量新增用户',tagList(
                                        fluidRow(column(4,box(
                                          title = "操作区域", width = NULL, solidHeader = TRUE, status = "primary",
                                          mdl_file('usr_file','上传用户模板',fileType = '.xlsx'),
                                          actionButton('usr_preview','预览'),
                                          actionButton('usr_upload','批量新增')
                                        )),
                                        column(8, box(
                                          title = "报表区域", width = NULL, solidHeader = TRUE, status = "primary",
                                          
                                          mdl_dataTable('usr_info','新增用户列表')
                                        )
                                        ))
                                        
                                      )),
                                      tabPanel('用户管理报表',tagList(
                                        fluidRow(column(4,box(
                                          title = "操作区域", width = NULL, solidHeader = TRUE, status = "primary",
                                          mdl_download_button('um_userInfo_dl','下载用户信息')
                                        )),
                                        column(8, box(
                                          title = "用户区域", width = NULL, solidHeader = TRUE, status = "primary",
                                          mdl_dataTable('um_userInfo','用户信息')
                                        )
                                        ))
                                        
                                        
                                      ))
                                      
                                      
                               )
                        )
                      )
)