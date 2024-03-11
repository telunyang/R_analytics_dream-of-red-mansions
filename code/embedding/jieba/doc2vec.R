library(jiebaR)
library(jiebaRD)
library(rjson)
library(tidyverse)
library(word2vec)
library(readtext)

# 讀取 json
json <- fromJSON(file = "dataset/version_1.json")

# 轉換成 dataframe
df <- as.data.frame(json)

# 讀取 word2vec 模型
model <- word2vec::read.word2vec(file = "models/word2vec_jieba.bin")

# 空向量，放置斷句後的 article
docs = c()

# Jieba 斷詞 (不保留標點符號)
tokenizer <- worker(symbol=F)

# 將斷詞後的 article 加入 list
for(i in 1:nrow(df)){
    print(i)
    
    # 建立斷詞
    words <- segment(df[i, 'json'], tokenizer)
    
    # 將斷詞透過空格合併，以符合訓練資料格式
    segmented_text <- stringr::str_c(words, collapse = " ") %>% c()

    # 整合文章斷詞
    docs <- rbind(docs, segmented_text)
}

# 將前面的文章轉成 vector
vectors = doc2vec(object=model, newdata = docs, split=' ')

# 向量預覽
vectors[1,] # 第 1 回
vectors[2,] # 第 2 回


# 建立一個包含 "dim1", "dim2", ..., "dimN" 的欄位名稱
col_names <- paste0("dim", 1:length(vectors[1,]))

# 轉換向量成為 dataframe
df_csv <- data.frame(matrix(vectors, nrow = nrow(vectors), ncol = length(vectors[1,]), byrow = TRUE))

# 將 dataframe 的欄位名稱設為 "dim1", "dim2", ..., "dimN"
names(df_csv) <- col_names

# 加入 doc_id
doc_id <- 1:nrow(vectors)
df_csv$doc_id <- doc_id

# 將 df 中的欄位名稱儲存到一個變數
col_names <- names(df_csv)

# 從 col_names 中移除 "doc_id"
col_names <- col_names[col_names != "doc_id"]

# 將 "doc_id" 加到 col_names 的最前面
col_names <- c("doc_id", col_names)

# 重新排列 df 的欄位順序
df_csv <- df_csv[, col_names]

# 建立 csv 資料夾
dir.create('csv', recursive = TRUE, showWarnings = FALSE)

# 儲存 csv
write.csv(df_csv, 'csv/df_jieba.csv', row.names = FALSE, quote = FALSE)
