menu_majority <- tabItem(tabName = "majority",
                         fluidRow(
                           column(12,   tabBox(
                             title = "报表分析工作台",width = 12,
                             # The id lets us use input$tabset1 on the server to find the current tab
                             id = "tabset_mngrRpt", height = "600px",
                             tabPanel("报表1", 
                                      tagList(
                                        fluidRow(
                                          column(4,     box(
                                            title = "选择数据", width = NULL, solidHeader = TRUE, status = "primary",
                                            'operation here'
                                            
                                          )),
                                          column(8,box(
                                            title = "选择数据预览", width = NULL, solidHeader = TRUE, status = "primary",
                                            'data here'
                                          )))
                                      )),
                             tabPanel("报表2", 
                                      tagList(
                                        fluidRow(
                                          column(4,     box(
                                            title = "上传数据", width = NULL, solidHeader = TRUE, status = "primary",
                                            'operation here'
                                            
                                          )),
                                          column(8,box(
                                            title = "上传数据预览", width = NULL, solidHeader = TRUE, status = "primary",
                                            'data here'
                                          )))
                                      )),
                             tabPanel("报表3", 
                                      tagList(
                                        fluidRow(
                                          column(4,     box(
                                            title = "上传数据", width = NULL, solidHeader = TRUE, status = "primary",
                                            'operation here'
                                            
                                          )),
                                          column(8,box(
                                            title = "上传数据预览", width = NULL, solidHeader = TRUE, status = "primary",
                                            'data here'
                                          )))
                                      )),
                             tabPanel("报表4", 
                                      tagList(
                                        fluidRow(
                                          column(4,     box(
                                            title = "上传数据", width = NULL, solidHeader = TRUE, status = "primary",
                                            'operation here'
                                            
                                          )),
                                          column(8,box(
                                            title = "上传数据预览", width = NULL, solidHeader = TRUE, status = "primary",
                                            'data here'
                                          )))
                                      )),
                             tabPanel("报表5", 
                                      tagList(
                                        fluidRow(
                                          column(4,     box(
                                            title = "上传数据", width = NULL, solidHeader = TRUE, status = "primary",
                                            'operation here'
                                            
                                          )),
                                          column(8,box(
                                            title = "上传数据预览", width = NULL, solidHeader = TRUE, status = "primary",
                                            'data here'
                                          )))
                                      ))
                           ))
                           
                         )
)