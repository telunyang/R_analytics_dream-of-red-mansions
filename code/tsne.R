args = commandArgs(trailingOnly=TRUE)

if (length(args)==0) {
  stop("USAGE: Rscript code/tsne.R --input data/csvfortrain --output results/tsne", call.=FALSE)
}

f_in <- NA
f_out <- NA

for (i in args) {
  if (i == '--input') {
    f_in <- args[which(args==i)+1]
  } 
  if (i == '--output') {
    f_out <- args[which(args==i)+1]
  }
}

# 載入所需套件
library(Rtsne)
library(plotly)

file_name_list = list('df_bert_chunking_768', 'df_bert_slidingWindow_768', 'df_bert768', 'df_ckip100', 'df_ckip768', 'df_jieba100', 'df_jieba768', 'df_jieba768_fre278')
for (i in file_name_list) {
  # 讀取資料
  data <- read.csv(paste(paste(paste(f_in, "/", sep = ""), i, sep = ""), '.csv', sep = ""))
  
  # 移除第1個欄位
  data <- data[, -1]
  
  # 執行 t-SNE
  tsne_result <- Rtsne(data, dims = 3)
  
  # 建立資料框，結合 t-SNE 結果與資料索引
  tsne_3d <- data.frame(tsne_result$Y)
  tsne_3d <- cbind(tsne_3d, doc_id = 1:nrow(tsne_3d))
  
  # 將前80筆與後40筆資料分開
  group1 <- tsne_3d[1:80, ]
  group2 <- tsne_3d[81:120, ]
  
  # 視覺化資料分布
  plot <- plot_ly() %>%
    add_markers(data = group1, x = ~X1, y = ~X2, z = ~X3, color = I("blue"), size = 2, 
                text = ~paste("前80回", doc_id), name = "前80回") %>%
    add_markers(data = group2, x = ~X1, y = ~X2, z = ~X3, color = I("red"), size = 2, 
                text = ~paste("後40回", doc_id), name = "後40回") %>%
    layout(scene = list(xaxis = list(title = "Dimension 1"),
                        yaxis = list(title = "Dimension 2"),
                        zaxis = list(title = "Dimension 3")),
           hoverlabel = list(namelength = -1))
  
  # 建立 csv 資料夾
  dir.create(f_out, recursive = TRUE, showWarnings = FALSE)
  
  # 將結果存成html
  htmlwidgets::saveWidget(plot, paste(paste(paste(f_out, "/", sep = ""), i, sep = ""), '.html', sep = ""))
}

