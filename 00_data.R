# 设置app标题-----
#change log---


app_title <-'RDS-BOM管理软件V1.0';

# store data into rdbe in the rds database
app_id <- 'lcrds'

#设置数据库链接---

conn_be <- conn_rds('rdbe')

#lcrdspkg::Gtab_batchWrite_db(file="DM线束 BOM-V3-611-final.xlsx")

#设置链接---

conn_bom <- conn_rds('lcrds')







conn <- conn_rds('lcdb')
#sql <- 'select top 10 * from takewiki_mo_barcode '
#mydata <- sql_select(conn,sql)
#View(mydata)


query_barcode <- function(fbillno ='0219070193',order_asc = TRUE){
  if (order_asc){
    str_a <-'asc'
  }else{
    str_a <-'desc'
  }
  sql <- paste0("select * from  takewiki_mo_barcode
where FBillNo ='",fbillno,"'
order by  FBarcode  ",str_a)
  r <- tsda::sql_select(conn,sql)
  return(r)
  
}


query_barcode_chartNo <- function(fchartNo ='P207012C134G01',fbillno ='',order_asc = TRUE){
  if (order_asc){
    str_a <-'asc'
  }else{
    str_a <-'desc'
  }
  if(len(fbillno)==0)
  {
    str_bill <-""
  }else{
    str_bill <-paste0(" and fbillno =  '",fbillno,"'  ")
  }
  sql <- paste0("select FBarcode as '二维码',FChartNumber '图号',FBillNo as '生产任务单号' from  takewiki_mo_barcode
where FChartNumber ='",fchartNo,"'",str_bill," 
order by  FBarcode  ",str_a)
  print(sql)
  r <- tsda::sql_select(conn,sql)
  return(r)
  
}


#查询外部条码----
get_extBarCode_bySo <- function(conn,fbillno='bbc'){
  sql <-paste0("select FSoNo ,FChartNo,FBarcode from takewiki_ext_barcode
where FSoNo ='",fbillno,"'")
  res <- tsda::sql_select(conn,sql)
  return(res)
}

#查询内部条码
get_innerBarCode_bySo <- function(conn,fbillno='bbc'){
  sql <-paste0("select FSoNo ,FChartNo,FBarcode from takewiki_inner_barcode
where FSoNo ='",fbillno,"'")
  res <- tsda::sql_select(conn,sql)
  return(res)
  
}


alloc_barcode <- function(data_ext,data_inner){
  ncount_ext <- nrow(data_ext);
  ncount_inner <- nrow(data_inner);
  #按图事情进行分解
  data_ext_split <- split(data_ext, data_ext$FChartNo);
  #检查外部条码可以分解为图号数量
  ncount_chartNo <- length(data_ext_split);
  r <-lapply(1:ncount_chartNo, function(i){
    data_ext_chartNo <-data_ext_split[[i]];
    chartNoItem <- unique(data_ext_chartNo$FChartNo);
    data_inner_chartNo <-data_inner[data_inner$FChartNo == chartNoItem ,'FBarcode',drop=FALSE];
    ncount_data_inner_chartNo <- nrow(data_inner_chartNo);
    if(ncount_data_inner_chartNo >0){
      #print(class(data_ext_chartNo))
      #print(class(data_inner_chartNo))
      res <- tsdo::allocate(data_ext_chartNo,data_inner_chartNo)
      #res <- as.data.frame(res)
      #print(class(res))
      return(res)
    }else{
      
    }
    
    
  })
  #print(r)
  res <- do.call('rbind',r)
  names(res)<-c('FSoNo','FChartNo','FBarcode_ext','FBarcode_inner')
  return(res)
  
}


barcode_allocate_auto <-function(conn,fbillno='bbc'){
  data_ext <-get_extBarCode_bySo(conn,fbillno);
  data_inner <-get_innerBarCode_bySo(conn,fbillno);
  res <- alloc_barcode(data_ext,data_inner);
  if(nrow(res) >0){
    tsda::upload_data(conn,'takewiki_barcode_allocate_auto',res)
  }
}

#显示预览数据
barcode_match_preview <- function(conn,fbillno='bbc'){
  sql <- paste0("select * from takewiki_barcode_allocate_auto
where FSoNo = '",fbillno,"'")
  r <- tsda::sql_select(conn,sql)
  return(r)
}



#修改配货单
getBooks <- function(fbillno='bbc') {
  res <- barcode_match_preview(conn,)
}



##### Callback functions.
books.insert.callback <- function(data, row ,table='t_test',f=getBooks,id_var='fid') {
  sql_header <- sql_gen_insert(conn,table)
  fieldList <-sql_fieldInfo(conn,table)
  ncount <-nrow(fieldList)
  res <- character(ncount)
  for (i in 1:ncount){
    col_Insert <-fieldList[i,'FFieldName']
    type <-fieldList[i,'FTypeName']
    if(col_Insert == id_var){
      res[i] <-paste0(' ',getMax_id(conn,table,id_var),' ')
    }else{
      res[i] <- format_to_sqlInsert(type)(data[row,col_Insert])
    }
    
  }
  sql_body <- paste0(res,collapse = ',')
  query <-paste0(sql_header,sql_body,")")
  
  print(query) # For debugging
  tsda::sql_update(conn, query)
  return(f())
}

books.update.callback <- function(data, olddata, row,
                                  table='takewiki_barcode_allocate_auto',
                                  f=getBooks,
                                  edit.cols = c('FBarcode_ext','FBarcode_inner'),
                                  id_var='FBarcode_ext',
                                  fbillno='bbc') 
{
  sql_header <- sql_gen_update(table);
  fieldList <-sql_fieldInfo(conn,table)
  ncount <-length(edit.cols)
  res <- character(ncount)
  for (i in 1:ncount){
    col_Update <-edit.cols[i]
    #col_Insert <-fieldList[fieldList$,'FFieldName']
    type <-fieldList[fieldList$FFieldName == col_Update,'FTypeName']
    res[i] <- paste0(' ',col_Update,' = ',format_to_sqlUpdate(type)(data[row,col_Update]))
    
    
  }
  sql_body <- paste0(res,collapse = ',')
  sql_tail <-paste0(' where ',id_var," = '",data[row,id_var],"'")
  query <- paste0(sql_header,sql_body,sql_tail)
  
  print(query) # For debugging
  tsda::sql_update(conn, query)
  return(f(fbillno))
}

books.delete.callback <- function(data, row ,table ='takewiki_barcode_allocate_auto',f=getBooks,id_var='FBarcode_ext',fbillno='bbc') {
  sql_header <- sql_gen_delete(table);
  sql_tail <-paste0('  ',id_var,' = ',data[row,id_var])
  query <- paste0(sql_header,sql_tail)
  
  #query <- paste0("DELETE FROM  ",table,"  WHERE id = ", data[row,]$id)
  print(query)
  tsda::sql_update(conn, query)
  return(f(fbillno))
}





