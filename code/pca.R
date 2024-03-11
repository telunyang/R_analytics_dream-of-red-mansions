args = commandArgs(trailingOnly=TRUE)

if (length(args)==0) {
  stop("USAGE: Rscript code/pca.R --input data/csvfortrain --output results/pca", call.=FALSE)
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
library(stats)
library(plotly)

file_name_list = list('df_bert_chunking_768', 'df_bert_slidingWindow_768', 'df_bert768', 'df_ckip100', 'df_ckip768', 'df_jieba100', 'df_jieba768', 'df_jieba768_fre278')
for (i in file_name_list) {
  # 讀取資料
  data <- read.csv(paste(paste(paste(f_in, "/", sep = ""), i, sep = ""), '.csv', sep = ""))
  
  # 移除第1個欄位
  data <- data[, -1]
  
  # 執行主成分分析 (PCA)
  pca <- prcomp(data, center = TRUE, scale. = TRUE, retx = TRUE)
  
  # 提取前3個主成分
  pca_3d <- data.frame(pca$x[, 1:3])
  
  # 建立資料框，結合主成分結果與資料索引
  pca_3d <- cbind(pca_3d, doc_id = 1:nrow(pca_3d))
  
  # 將前80筆與後40筆資料分開
  group1 <- pca_3d[1:80, ]
  group2 <- pca_3d[81:120, ]
  
  # 視覺化資料分布
  plot <- plot_ly() %>%
    add_markers(data = group1, x = ~PC1, y = ~PC2, z = ~PC3, color = I("blue"), size = 2,
                text = ~paste("前80回", doc_id), name = "前80回") %>%
    add_markers(data = group2, x = ~PC1, y = ~PC2, z = ~PC3, color = I("red"), size = 2,
                text = ~paste("後40回", doc_id), name = "後40回") %>%
    layout(scene = list(xaxis = list(title = "PC1"),
                        yaxis = list(title = "PC2"),
                        zaxis = list(title = "PC3")))
  
  # 建立 csv 資料夾
  dir.create(f_out, recursive = TRUE, showWarnings = FALSE)
  
  # 將結果存成html
  htmlwidgets::saveWidget(plot, paste(paste(paste(f_out, "/", sep = ""), i, sep = ""), '.html', sep = ""))
}

