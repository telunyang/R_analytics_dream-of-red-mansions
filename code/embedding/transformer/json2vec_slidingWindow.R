library(reticulate)
library(rjson)

# 指定 conda 環境
use_condaenv("C:\\Users\\darren\\anaconda3\\envs\\da", required=TRUE)

# 載入套件
transformers <- import("transformers")
torch <- import("torch")

# 載入 BERT 模型
model_name <- "bert-base-chinese"
model <- transformers$BertModel$from_pretrained(model_name)

# 使用 tokenizer 將文章轉換為模型所需的輸入格式
tokenizer <- transformers$BertTokenizer$from_pretrained(model_name)

# 讀取 json
json <- fromJSON(file = "./dataset/version_1_clean.json")

# 轉換成 dataframe
df <- as.data.frame(json)

# 建立向量，放置每一回小說
vectors <- c()

# 將每一回小說建立 embedding
for(i in 1:nrow(df)){ 
    print(paste("第 ", i, " 回"))
    
    # 要進行 embedding 的文章
    text <- df[i, 'json']
    
    # 初始化加總用的 embedding
    all_embeddings <- list()
    
    # 取得文字總數
    len_text <- nchar(enc2utf8(text))
    
    print(paste("有 ", len_text, " 個字"))
    
    # sliding 後的數量，大於 len_text 就該停止
    sliding <- 0
    
    # 索引初始化
    idx <- 1
    
    # 透過 sliding window 建立 embedding
    while (TRUE){
        print(paste("sliding: ", sliding))
        
        # 判斷 sliding 後的長度，若是大於文章字數，則跳離迴圈
        if (sliding >= len_text) break
            
        # 取得 text 的 input_ids (因為 bert 的 max_seq_length 是 512 (包括 [CLS] 和 [SEP])，所以一篇幾千字的文章，必須只能裁切/保留 510 個字)
        input_ids <- torch$tensor(tokenizer$encode(text[sliding + 1: sliding + 510], truncation=TRUE))$unsqueeze(as.integer(0))
        
        # 輸出 hidden_state
        outputs <- model(input_ids)
        
        # 建立 embeddings
        all_embeddings[[idx]] <- outputs[["last_hidden_state"]][0][0]$detach()$numpy()
        
        # 累計 sliding
        sliding <- sliding + 100
        
        # 計算 index
        idx <- idx + 1
        
        # 釋放變數
        rm(input_ids, outputs)
    }
    
    # 將嵌入向量列表轉換為矩陣
    embedding_matrix <- t(simplify2array(all_embeddings))
    
    # 透過 colMeans() 函數計算平均數
    document_vector <- colMeans(embedding_matrix)
    
    # 整合 vector
    vectors <- rbind(vectors, document_vector)
    
    # 釋放變數
    rm(embedding_matrix, all_embeddings, document_vector, len_text, text)
}



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
write.csv(df_csv, 'csv/df_bert_slidingWindow.csv', row.names = FALSE, quote = FALSE)
