args = commandArgs(trailingOnly=TRUE)

if (length(args)==0) {
  stop("USAGE: Rscript code/wordembeddingspace.R --input data/dataset/version_1_clean.json --output results/umap", call.=FALSE)
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

library(jiebaR)
library(jiebaRD)
library(rjson)
library(tidyverse)
library(word2vec)
library(readtext)
library(uwot)
library(ggplot2)
library(plotly)

# 讀取 json
json <- fromJSON(file = f_in)

# 轉換成 dataframe
df <- as.data.frame(json)

# 將前80與後40分2個暫存字串
forward_tmp <- ''
for (i in c(1: 80)){
  forward_tmp <- paste(forward_tmp, df$json[i], sep = "")
}
backward_tmp <- ''
for (i in c(81: 120)){
  backward_tmp <- paste(backward_tmp, df$json[i], sep = "")
}

# Jieba 斷詞 (不保留標點符號)
tokenizer <- worker(symbol=F)
forward_words <- segment(forward_tmp, tokenizer)
backward_words <- segment(backward_tmp, tokenizer)

# 計算詞頻
forward_word_freq <- table(forward_words)
backward_word_freq <- table(backward_words)

fre_list = list(278, 500, 1000)
for (i in fre_list) {
  # 取得出現頻率最高的常用字
  forward_top_words <- head(sort(forward_word_freq, decreasing = TRUE), i)
  backward_top_words <- head(sort(backward_word_freq, decreasing = TRUE), i)
  
  # 移除數字
  forward_segmented_text <- names(forward_top_words)
  backward_segmented_text <- names(backward_top_words)
  
  # 將斷詞透過空格合併，以符合訓練資料格式
  forward_segmented_text_save <- stringr::str_c(forward_segmented_text, collapse = " ") %>% c()
  backward_segmented_text_save <- stringr::str_c(backward_segmented_text, collapse = " ") %>% c()
  
  # 建立放置斷詞的資料夾
  dir.create('data/tokenized', recursive = TRUE, showWarnings = FALSE)
  
  # 將斷詞結果儲存在 txt 中
  readr::write_file(
    forward_segmented_text_save, 
    file='data/tokenized/forward_tokenized_words_jieba.txt')
  readr::write_file(
    backward_segmented_text_save, 
    file='data/tokenized/backward_tokenized_words_jieba.txt')
  
  # 訓練 word2vec 模型
  forward_model <- word2vec(
    x = 'data/tokenized/forward_tokenized_words_jieba.txt',
    dim = 768,
    iter = 20,
    threads = parallel::detectCores())
  backward_model <- word2vec(
    x = 'data/tokenized/backward_tokenized_words_jieba.txt',
    dim = 768,
    iter = 20,
    threads = parallel::detectCores())
  
  # 建立放置模型的資料夾
  dir.create('data/models', recursive = TRUE, showWarnings = FALSE)
  
  # 儲存模型
  word2vec::write.word2vec(
    x = forward_model,
    file = "data/models/forward_word2vec_jieba.bin")
  word2vec::write.word2vec(
    x = backward_model,
    file = "data/models/backward_word2vec_jieba.bin")
  
  
  # 讀取 word2vec 模型
  model <- word2vec::read.word2vec(file = "data/models/word2vec_jieba.bin")
  # forward_model <- word2vec::read.word2vec(file = "data/models/forward_word2vec_jieba.bin")
  # backward_model <- word2vec::read.word2vec(file = "data/models/backward_word2vec_jieba.bin")
  
  embedding <- as.matrix(model)
  # forward_embedding <- as.matrix(forward_model)
  # backward_embedding <- as.matrix(backward_model)
  
  viz <- umap(embedding, n_neighbors = 15, n_threads = 2)
  viz3 <- umap(embedding, n_neighbors = 15, n_threads = 2, n_components = 3)
  # forward_viz <- umap(forward_embedding, n_neighbors = 15, n_threads = 2)
  # backward_viz <- umap(backward_embedding, n_neighbors = 15, n_threads = 2)
  
  # 於最高詞頻的278個找出共同用詞
  common_elements <- intersect(forward_segmented_text, backward_segmented_text)
  # 只取非共同用詞
  forward_segmented_text <- setdiff(forward_segmented_text, common_elements)
  backward_segmented_text <- setdiff(backward_segmented_text, common_elements)
  forward_viz <- viz[row.names(viz) %in% forward_segmented_text, ]
  backward_viz <- viz[row.names(viz) %in% backward_segmented_text, ]
  forward_viz3 <- viz3[row.names(viz3) %in% forward_segmented_text, ]
  backward_viz3 <- viz3[row.names(viz3) %in% backward_segmented_text, ]
  
  # 將資料組成資料框
  data <- data.frame(x = viz[, 1], y = viz[, 2], row_names = rownames(viz))
  forward_data <- data.frame(x = forward_viz[, 1], y = forward_viz[, 2], row_names = rownames(forward_viz))
  backward_data <- data.frame(x = backward_viz[, 1], y = backward_viz[, 2], row_names = rownames(backward_viz))
  forward_data3 <- data.frame(x = forward_viz3[, 1], y = forward_viz3[, 2], z = forward_viz3[, 3], row_names = rownames(forward_viz3))
  backward_data3 <- data.frame(x = backward_viz3[, 1], y = backward_viz3[, 2], z = backward_viz3[, 3], row_names = rownames(backward_viz3))
  
  # 使用 ggplot2 繪製點散圖
  ggplot(data, aes(x = x, y = y, label = row_names)) +
    geom_point(color = "blue") +
    geom_text(vjust = -1, color = "black")
  labs(x = "X", y = "Y", title = "word2vec in 2D")
  plot1 <- ggplot(forward_data, aes(x = x, y = y, label = row_names)) +
    geom_point(color = "blue") +
    geom_text(vjust = -1, color = "black") +
    labs(x = "X", y = "Y", title = "前80回 - word2vec in 2D") +
    coord_cartesian(xlim = c(min(-3), max(3)),
                    ylim = c(min(-2.5), max(2.5)))
  plot2 <- ggplot(backward_data, aes(x = x, y = y, label = row_names)) +
    geom_point(color = "red") +
    geom_text(vjust = -1, color = "black") +
    labs(x = "X", y = "Y", title = "後40回 - word2vec in 2D") +
    coord_cartesian(xlim = c(min(-3), max(3)),
                    ylim = c(min(-2.5), max(2.5)))
  
  library(gridExtra)
  # 2張2維圖同時呈現
  grid.arrange(plot1, plot2, ncol = 2)
  
  # 2維圖
  combined_data <- rbind(forward_data, backward_data)
  ggplot(combined_data, aes(x = x, y = y)) +
    geom_point(data = forward_data, aes(color = "blue")) +
    geom_point(data = backward_data, aes(color = "red")) +
    geom_text(aes(label = row_names), vjust = -1, color = "black") +
    labs(x = "X", y = "Y", title = "word2vec in 2D") +
    scale_color_manual(values = c("blue", "red"), labels = c("前80回", "後40回"))
  
  # 3維圖
  plot <- plot_ly() %>%
    add_markers(data = forward_data3, x = ~x, y = ~y, z = ~z, color = I("blue"), size = 2,
                text = ~row_names, name = "前80回") %>%
    add_markers(data = backward_data3, x = ~x, y = ~y, z = ~z, color = I("red"), size = 2,
                text = ~row_names, name = "後40回") %>%
    add_text(data = forward_data3, x = ~x, y = ~y, z = ~z, text = ~row_names, 
             textposition = "top", mode = "text", name = "前80回") %>%
    add_text(data = backward_data3, x = ~x, y = ~y, z = ~z, text = ~row_names, 
             textposition = "top", mode = "text", name = "後40回") %>%
    layout(scene = list(xaxis = list(title = "x"),
                        yaxis = list(title = "y"),
                        zaxis = list(title = "z")))
  
  # 建立 csv 資料夾
  dir.create(f_out, recursive = TRUE, showWarnings = FALSE)
  
  # 將結果存成html
  htmlwidgets::saveWidget(plot, paste(paste(paste(f_out, "/", sep = ""), i, sep = ""), '.html', sep = ""))
}
