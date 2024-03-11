library(reticulate)
library(rjson)
library(word2vec)
library(tidyverse)

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

# 將所有文章合併在一個暫存字串
str_tmp <- ''
for (i in 1:nrow(df)){ 
    str_tmp <- paste(str_tmp, df$json[i], sep = "")
}

# 將 list 當中的每一段文章進行斷詞 (目前這裡是把 120 回小說全放在一起斷)
word_sentence_list <- ws(list(str_tmp))

# 將斷詞透過空格合併，以符合訓練資料格式
segmented_text <- stringr::str_c(word_sentence_list[[1]], collapse = " ") %>% c()

# 建立放置斷詞的資料夾
dir.create('./tokenized', recursive = TRUE, showWarnings = FALSE)

# 將斷詞結果儲存在 txt 中
readr::write_file(
    segmented_text,
    file='./tokenized/tokenized_words_ckip.txt')
