menu_book <- tabItem(tabName = "book",
                     fluidRow(
                       column(12,   tabBox(
                         title = "BOM同步工作台",width = 12,
                         # The id lets us use input$tabset1 on the server to find the current tab
                         id = "tabset_bomSync", height = "600px",
                         tabPanel("新物料查询", 
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
                        
                       
                         tabPanel("物料导出到ERP", 
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