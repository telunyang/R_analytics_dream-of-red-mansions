library(jiebaR)
library(jiebaRD)
library(rjson)
library(tidyverse)
library(word2vec)
library(readtext)

# 讀取 json
json <- fromJSON(file = "dataset/version_1_clean.json")

# 轉換成 dataframe
df <- as.data.frame(json)

# 將所有文章合併在一個暫存字串
str_tmp <- ''
for (i in c(1: nrow(df))){
    str_tmp <- paste(str_tmp, df$json[i], sep = "")
}

# Jieba 斷詞 (不保留標點符號)
tokenizer <- worker(symbol=F)
words <- segment(str_tmp, tokenizer)

# 將斷詞透過空格合併，以符合訓練資料格式
segmented_text <- stringr::str_c(words, collapse = " ") %>% c()

# 建立放置斷詞的資料夾
dir.create('tokenized', recursive = TRUE, showWarnings = FALSE)

# 將斷詞結果儲存在 txt 中
readr::write_file(
    segmented_text, 
    file='tokenized/tokenized_words_jieba.txt')
