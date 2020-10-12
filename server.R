

#shinyserver start point----
 shinyServer(function(input, output,session) {
    #00-基础框设置-------------
    #读取用户列表
    user_base <- getUsers(conn_be,app_id)
    
    
    
    credentials <- callModule(shinyauthr::login, "login", 
                              data = user_base,
                              user_col = Fuser,
                              pwd_col = Fpassword,
                              hashed = TRUE,
                              algo = "md5",
                              log_out = reactive(logout_init()))
    
    
    
    logout_init <- callModule(shinyauthr::logout, "logout", reactive(credentials()$user_auth))
    
    observe({
       if(credentials()$user_auth) {
          shinyjs::removeClass(selector = "body", class = "sidebar-collapse")
       } else {
          shinyjs::addClass(selector = "body", class = "sidebar-collapse")
       }
    })
    
    user_info <- reactive({credentials()$info})
    
    #显示用户信息
    output$show_user <- renderUI({
       req(credentials()$user_auth)
       
       dropdownButton(
          fluidRow(  box(
             title = NULL, status = "primary", width = 12,solidHeader = FALSE,
             collapsible = FALSE,collapsed = FALSE,background = 'black',
             #2.01.01工具栏选项--------
             
             
             actionLink('cu_updatePwd',label ='修改密码',icon = icon('gear') ),
             br(),
             br(),
             actionLink('cu_UserInfo',label = '用户信息',icon = icon('address-card')),
             br(),
             br(),
             actionLink(inputId = "closeCuMenu",
                        label = "关闭菜单",icon =icon('window-close' ))
             
             
          )) 
          ,
          circle = FALSE, status = "primary", icon = icon("user"), width = "100px",
          tooltip = FALSE,label = user_info()$Fuser,right = TRUE,inputId = 'UserDropDownMenu'
       )
       #
       
       
    })
    
    observeEvent(input$closeCuMenu,{
       toggleDropdownButton(inputId = "UserDropDownMenu")
    }
    )
    
    #修改密码
    observeEvent(input$cu_updatePwd,{
       req(credentials()$user_auth)
       
       showModal(modalDialog(title = paste0("修改",user_info()$Fuser,"登录密码"),
                             
                             mdl_password('cu_originalPwd',label = '输入原密码'),
                             mdl_password('cu_setNewPwd',label = '输入新密码'),
                             mdl_password('cu_RepNewPwd',label = '重复新密码'),
                             
                             footer = column(shiny::modalButton('取消'),
                                             shiny::actionButton('cu_savePassword', '保存'),
                                             width=12),
                             size = 'm'
       ))
    })
    
    #处理密码修改
    
    var_originalPwd <-var_password('cu_originalPwd')
    var_setNewPwd <- var_password('cu_setNewPwd')
    var_RepNewPwd <- var_password('cu_RepNewPwd')
    
    observeEvent(input$cu_savePassword,{
       req(credentials()$user_auth)
       #获取用户参数并进行加密处理
       var_originalPwd <- password_md5(var_originalPwd())
       var_setNewPwd <-password_md5(var_setNewPwd())
       var_RepNewPwd <- password_md5(var_RepNewPwd())
       check_originalPwd <- password_checkOriginal(fappId = app_id,fuser =user_info()$Fuser,fpassword = var_originalPwd)
       check_newPwd <- password_equal(var_setNewPwd,var_RepNewPwd)
       if(check_originalPwd){
          #原始密码正确
          #进一步处理
          if(check_newPwd){
             password_setNew(fappId = app_id,fuser =user_info()$Fuser,fpassword = var_setNewPwd)
             pop_notice('新密码设置成功:)') 
             shiny::removeModal()
             
          }else{
             pop_notice('两次输入的密码不一致，请重试:(') 
          }
          
          
       }else{
          pop_notice('原始密码不对，请重试:(')
       }
       
       
       
       
       
    }
    )
    
    
    
    #查看用户信息
    
    #修改密码
    observeEvent(input$cu_UserInfo,{
       req(credentials()$user_auth)
       
       user_detail <-function(fkey){
          res <-tsui::userQueryField(conn = conn_be,app_id = app_id,user =user_info()$Fuser,key = fkey)
          return(res)
       } 
       
       
       showModal(modalDialog(title = paste0("查看",user_info()$Fuser,"用户信息"),
                             
                             textInput('cu_info_name',label = '姓名:',value =user_info()$Fname ),
                             textInput('cu_info_role',label = '角色:',value =user_info()$Fpermissions ),
                             textInput('cu_info_email',label = '邮箱:',value =user_detail('Femail') ),
                             textInput('cu_info_phone',label = '手机:',value =user_detail('Fphone') ),
                             textInput('cu_info_rpa',label = 'RPA账号:',value =user_detail('Frpa') ),
                             textInput('cu_info_dept',label = '部门:',value =user_detail('Fdepartment') ),
                             textInput('cu_info_company',label = '公司:',value =user_detail('Fcompany') ),
                             
                             
                             footer = column(shiny::modalButton('确认(不保存修改)'),
                                             
                                             width=12),
                             size = 'm'
       ))
    })
    
    
    
    #针对用户信息进行处理
    
    sidebarMenu <- reactive({
       
       res <- setSideBarMenu(conn_rds('rdbe'),app_id,user_info()$Fpermissions)
       return(res)
    })
    
    
    #针对侧边栏进行控制
    output$show_sidebarMenu <- renderUI({
       if(credentials()$user_auth){
          return(sidebarMenu())
       } else{
          return(NULL) 
       }
       
       
    })
    
    #针对工作区进行控制
    output$show_workAreaSetting <- renderUI({
       if(credentials()$user_auth){
          return(workAreaSetting)
       } else{
          return(NULL) 
       }
       
       
    })
    
    

    #4.条码配货模块相关代码------- 
    file_ext_barcode <- var_file('file_ext_barcode')
    rule_ext_sorted <- var_ListChoose1('rule_ext_sorted');
    
    var_ext_so <- var_text('filter_ext_so')
    
    
    data_ext_barcode <- reactive({
      file_ext_barcode <- file_ext_barcode();
      ext_so <- var_ext_so()
      res <- readxl::read_excel(file_ext_barcode);
      res <- res[,c('订单号',	'物料号'	,'二维码','印版线束')];
      
      if(len(ext_so) >0){
        res <- res[res$`订单号` == ext_so & !is.na(res$`订单号`),]
        print(res)
      }else(
        print(res)
      )
      res <- res[order(res$`二维码`,decreasing = rule_ext_sorted()),]
      return(res);
      
    })
    
    data_ext_barcode_pre <- reactive({
      res <-data_ext_barcode()
      # res <- head(res)
      return(res)
      
    })
    
    data_ext_barcode_db<- reactive({
      res <-data_ext_barcode()
      names(res) <-c('FSoNo','FChartNo','FBarcode','FNote')
      res$FNote <- tsdo::na_replace(res$FNote,'')
      res$FNote <- as.character(res$FNote)
      # res <- head(res)
      return(res)
      
    })
    
    
    
    observeEvent(input$btn_ext_barcode,{
      run_dataTable2('preview_ext_barcode',data_ext_barcode_db())
    })
    
    var_barcode <- var_text('mo_chartNo')
    var_inner_sort <- var_ListChoose1('rule_inner_sorted')
    
    #处理上传事项
    observeEvent(input$btn_ext_barcode_upload,{
      
      tsda::upload_data(conn,'takewiki_ext_barcode',data_ext_barcode_db())
      pop_notice('已上传服务器')
    })
    
    
    #内部条码标签
    data_inner_barcode <-reactive({
      data <-query_barcode_chartNo(fchartNo = var_barcode(),fbillno=input$mo_fbillno,order_asc = var_inner_sort())
      return(data)
    })
    
    data_inner_barcode_db <- reactive({
      data <- data_inner_barcode()
      names(data) <-c('FBarcode','FChartNo','FMoNo')
      if(len(var_ext_so()) ==0){
        pop_notice('请在外部标签填写销售订单号')
        return(data)
      }else{
        res <- tsdo::df_addCol(data,'FSoNo',var_ext_so())
        res$FSoNo <- tsdo::na_replace(res$FSoNo,'')
        return(res)
      }
      
    })
    observeEvent(input$btn_inner_barcode,{
      
      data <- data_inner_barcode_db()
      run_dataTable2('preview_inner_barcode',data = data)
    })
    
    
    
    #处理内部条码上传逻辑
    observeEvent(input$btn_inner_barcode_upload,{
      
      
      
      tsda::upload_data(conn,'takewiki_inner_barcode',data_inner_barcode_db())
      pop_notice('已上传服务器')
      #code here 
      
    })
    
    
    #处理智能匹配的内容
    
    data_barcode_match_db <- reactive({
      res <-barcode_match_preview(conn,var_ext_so())
      return(res)
    })
    data_barcode_match_preview <- reactive({
      res <- data_barcode_match_db();
      names(res) <-c('销售订单号','图号','外部二维码','内部二维码')
      return(res)
    })
    
    observeEvent(input$match_do,{
      #code here
      barcode_allocate_auto(conn,var_ext_so())
      
    })
    
    observeEvent(input$match_preview,{
      run_dataTable2('preview_match_barcode', data_barcode_match_preview())
      
    })
    
    #人工修改
    books <- getBooks(var_ext_so())
    print(books)
    dtedit2(input, output,
            name = 'books',
            thedata = books,
            edit.cols = c('FBarcode_ext','FBarcode_inner'),
            edit.label.cols = c('外部二维码','内部二维码'),
            input.types = c(FBarcode_inner='textAreaInput'),
            #input.choices = list(fname = unique(unlist(books$fname))),
            view.cols = c('FSoNo','FChartNo','FBarcode_ext','FBarcode_inner'),
            view.captions = c('销售订单号','图号','外部二维码','内部二维码'),
            show.delete = F,
            show.update = T,
            show.insert = F,
            show.copy = F,
            callback.update = books.update.callback,
            callback.insert = books.insert.callback,
            callback.delete = books.delete.callback)
    
    
    
    #6.用户管理-----
    var_usr_file <- var_file('usr_file')
    
    
    data_user_add <- eventReactive(input$usr_preview,{
      
      res <-tsui::readUserFile(file = var_usr_file())
      return(res)
    })
    
    data_userName_New <- reactive({
      data <-data_user_add()
      res <- data$Fuser
      return(res)
    })
    
    observeEvent(input$usr_preview,{
      
      run_dataTable2('usr_info',data_user_add())
      
    })
    #批量新增按纽
    observeEvent(input$usr_upload,{
      
      newUser_flag <- caaspkg::getNewUsers(conn = conn_be,app_id = app_id,users = data_userName_New())
      print(newUser_flag)
      users_all <- data_user_add()
      users_filtered <- users_all[newUser_flag,]
      ncount <- nrow(users_filtered)
      if(ncount >0){
        tsui::userRight_upload(app_id = app_id,data = users_filtered)
        
        
        tsui::userInfo_upload(data = users_filtered,app_id = app_id)
        
        pop_notice(paste0('上传',ncount,"条用户记录！"))
        
      }else{
        pop_notice("上述用户已全部在系统中,请确认！")
        
      }
      
      
      
      
    })
    
   
   
   #处理BOM管理----
    
    
    #预览页签
    observeEvent(input$bq_sheet_preview,{
      
      file <- file_bom()
      data <- lcrdspkg::lc_bom_sheetName(file)
      data2 <- data.frame(`页签名称` = data,stringsAsFactors = F)
      run_dataTable2('bq_sheet_dataPreview',data2)
      
      
    })
    
    #跳转到G翻转表
    observeEvent(input$bq_toGtab,{
      updateTabsetPanel(session, "tabset_bomQuery",
                        selected = "G番表")
    })
    
    #格式化G翻转表
    file_bom <- var_file('bq_file')
    #选定的页答
    var_include_sheet <- var_text('bq_sheet_select')
    
    observeEvent(input$bq_formatG,{
      file <- file_bom()
      
      include_sheetNames <- var_include_sheet()
      print(include_sheetNames)
      if(is.null(include_sheetNames)){
        include_sheetNames <-NA
      }
      print(include_sheetNames)
      if(tsdo::len(include_sheetNames) == 0){
        include_sheetNames <-NA
      }
      
      print(include_sheetNames)
      lcrdspkg::Gtab_batchWrite_db(conn=conn_bom,file = file,include_sheetNames = include_sheetNames,show_progress = TRUE)
      
      pop_notice('G番表完成处理')
    })
    
    
    #处理下载数据--
    var_gtab_chartNo <- var_text('bq_Gtab_chartNo_input')
    
    data_gtab_dl <- eventReactive(input$bq_Gtab_chartNo_preview,{
      
      FchartNo <-var_gtab_chartNo()
      res <-lcrdspkg::Gtab_selectDB_byChartNo2(conn = conn_bom,FchartNo =FchartNo )
      return(res)
    })
    
    observeEvent(input$bq_Gtab_chartNo_preview,{
      
      data <- data_gtab_dl()
      FchartNo <-var_gtab_chartNo()
      filename <- paste0(FchartNo,"_G番表.xlsx")
      run_dataTable2('bq_Gtab_chartNo_dataShow',data = data)
      run_download_xlsx('bq_Gtab_chartNo_dl',data = data,filename = filename)
      
    })
    
    
    
    
    
    #跳转到L番表
    observeEvent(input$bq_goLtab,{
      updateTabsetPanel(session, "tabset_bomQuery",
                        selected = "L番表")
      
    })
    
    observeEvent(input$bq_formatL,{
      file <- file_bom()
      
      include_sheetNames <- var_include_sheet()
      print(include_sheetNames)
      if(is.null(include_sheetNames)){
        include_sheetNames <-NA
      }
      if(tsdo::len(include_sheetNames) == 0){
        include_sheetNames <-NA
      }
      print(include_sheetNames)
      lcrdspkg::Ltab_batchWrite_db(conn = conn_bom,file = file,include_sheetNames = include_sheetNames,show_progress = TRUE)
      pop_notice('L番表完成处理')
      
    })
    
    #处理L翻转表数据
    var_ltab_chartNo <- var_text('bq_Ltab_chartNo_input')
    
    data_ltab_dl <- eventReactive(input$bq_Ltab_chartNo_preview,{
      
      FchartNo <-var_ltab_chartNo()
      res <-lcrdspkg::Ltab_select_db2(conn=conn_bom,FchartNo = FchartNo)
      return(res)
    })
    
    observeEvent(input$bq_Ltab_chartNo_preview,{
      
      data <- data_ltab_dl()
      FchartNo <-var_ltab_chartNo()
      filename <- paste0(FchartNo,"_L番表.xlsx")
      run_dataTable2('bq_Ltab_chartNo_dataShow',data = data)
      run_download_xlsx('bq_Ltab_chartNo_dl',data = data,filename = filename)
      
    })
    
    
    #跳转到BOM运算
    
    observeEvent(input$bq_goCalcBom,{
      updateTabsetPanel(session, "tabset_bomQuery",
                        selected = "BOM运算")
      
      
      
    })
    #实现BOM运算逻辑
    observeEvent(input$bq_calcBom,{
      
      lcrdspkg::dm_dealAll2(conn=conn_bom,show_process = TRUE)
      pop_notice('BOM运算已完成')
      
      
      
    })
    
    #配置BOM速查---
    
    var_FchartNo <- var_text('bq_spare_partNo')
    var_FGtab <- var_text('bq_spare_GNo')
    var_FLtab <- var_text('bq_spare_LNo')
    db_bom_spare <- eventReactive(input$bq_spare_preview,{
      FchartNo <- var_FchartNo()
      FGtab <- var_FGtab()
      FLtab <- var_FLtab()
      
      res<- lcrdspkg::dm_selectDB_detail(conn=conn_bom,FchartNo = FchartNo,FParamG = FGtab,FParamL = FLtab)
      return(res)
      
    })
    
    observeEvent(input$bq_spare_preview,{
      data <- db_bom_spare()
      
      run_dataTable2('bq_spare_dataShow',data = data)
      pop_notice('配件查询已完成')
      run_download_xlsx('bq_spare_download',data = data,filename = '配件BOM查询下载.xlsx')
    })
    
    #处理DM数据--
    var_file_dm <- var_file('bq_dm_file')
    
    data_dm_detail <- eventReactive(input$bq_DM_preview,{
      file <- var_file_dm()
      print(file)
      sheetName <- input$bq_dm_sheetName
      print(sheetName)
      res <- lcrdspkg::dm_queryAll(file = file,sheet = sheetName,conn = conn_bom)
      print(res)
      return(res)
    })
    
    observeEvent(input$bq_DM_preview,{
      print('A')
      data <- data_dm_detail()
      print(data)
      run_dataTable2('bq_DM_dataShow',data = data)
      run_download_xlsx('bq_DM_download',data = data,filename = 'DM清单明细.xlsx')
      
      
    })


    
   
  
})
