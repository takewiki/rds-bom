menu_series<- tabItem(tabName = "series",
                      fluidRow(
                        column(12,   tabBox(
                          title = "配货单列表",width = 12,
                          # The id lets us use input$tabset1 on the server to find the current tab
                          id = "tabset_sd", height = "600px",
                          tabPanel("SMEC外部标签", 
                                   tagList(
                                     fluidRow(
                                       column(4,     box(
                                         title = "外部标签", width = NULL, solidHeader = TRUE, status = "primary",
                                         mdl_file('file_ext_barcode','选择外部标签文件'),
                                         mdl_ListChoose1('rule_ext_sorted','排序规则(外部标签)',list('二维码从小到大(升序)','二维码从大到小(降序)'),list(TRUE,FALSE),selected = TRUE),
                                         #mdl_ListChoose1('rule_ext_sorted2','处理规则',list(' 规则1','规则2'),list(FALSE,TRUE),selected = FALSE),
                                         mdl_text('filter_ext_so','销售订单号'),
                                         actionButton('btn_ext_barcode','预览外部标签'),
                                         use_pop(),
                                         actionButton('btn_ext_barcode_upload','上传服务器')
                                         
                                       )),
                                       column(8,box(
                                         title = "预览外部标签内容", width = NULL, solidHeader = TRUE, status = "primary",
                                         mdl_dataTable('preview_ext_barcode',label = '预览外部标签内容')
                                       )))
                                   )),
                          tabPanel("LC内部标签", 
                                   tagList(fluidRow(
                                     column(4, box(
                                       title = "LC内部标签", width = NULL, solidHeader = TRUE, status = "primary",
                                       
                                       mdl_text('mo_chartNo','请输入图号:'),
                                       textInput('mo_fbillno','请输入任务单号',''),
                                       mdl_ListChoose1('rule_inner_sorted','排序规则(内部标签)',list('二维码从小到大(升序)','二维码从大到小(降序)'),list(TRUE,FALSE),selected = TRUE),
                                       actionButton('btn_inner_barcode','查询内部标签'),
                                       actionButton('btn_inner_barcode_upload','上传服务器')
                                     )),
                                     column(8,box(
                                       title = "预览内部标签内容", width = NULL, solidHeader = TRUE, status = "primary",
                                       mdl_dataTable('preview_inner_barcode',label = '预览内部标签内容')
                                     ))))),
                          tabPanel("标签智能匹配", 
                                   tagList(fluidRow(
                                     column(4,   box(
                                       title = "匹配规则", width = NULL, solidHeader = TRUE, status = "primary",
                                       
                                       
                                       actionButton('match_do','智能匹配'),
                                       actionButton('match_preview','预览配货单'),
                                       mdl_download_button('match_dl','下载配货单')
                                     )),
                                     column(8, box(
                                       title = "预览配货单内容", width = NULL, solidHeader = TRUE, status = "primary",
                                       mdl_dataTable('preview_match_barcode',label = '预览配货单内容')
                                     ))))),
                          tabPanel("标签人工修改", 
                                   tagList(fluidRow(
                                     column(4,   box(
                                       title = "匹配规则", width = NULL, solidHeader = TRUE, status = "primary",
                                       mdl_download_button('match_dl2','下载配货单')
                                       
                                     )),
                                     column(8, box(
                                       title = "预览配货单内容", width = NULL, solidHeader = TRUE, status = "primary",
                                       h3('预览配货单内容'),
                                       uiOutput('books')
                                     )))))
                        ))
                        
                      )
)