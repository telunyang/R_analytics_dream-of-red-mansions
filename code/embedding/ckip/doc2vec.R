library(reticulate)
library(rjson)
library(word2vec)

# 指定 conda 環境
use_condaenv("C:\\Users\\darren\\anaconda3\\envs\\da", required=TRUE)
ckiptagger <- import("ckiptagger")

# 下載模型包 (尚未下載的話，可以執行這段程式碼，下載完建議註解，以免重複下載)
# ckiptagger$data_utils$download_data_gdown("./")

# 使用斷詞工具
data_path <- "./data"
ws <- ckiptagger$WS(data_path)

# 讀取 json
json <- fromJSON(file = "./dataset/version_1_clean.json")

# 轉換成 dataframe
df <- as.data.frame(json)

# 讀取 word2vec 模型
model <- word2vec::read.word2vec(file = "./models/word2vec_ckip.bin")

# 建立 list，放置每一回小說，之後一起拿去 ckiptagger 斷詞
docs <- c()

# 將斷詞後的 article 加入 list
for(i in 1:nrow(df)){
    print(i)
    
    # 將 list 當中的每一段文章進行斷詞
    word_sentence_list <- ws(list(df[i, 'json']))
    
    # 將斷詞透過空格合併，以符合訓練資料格式
    segmented_text <- stringr::str_c(word_sentence_list[[1]], collapse = " ") %>% c()
    
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
write.csv(df_csv, 'csv/df_ckip.csv', row.names = FALSE, quote = FALSE)
