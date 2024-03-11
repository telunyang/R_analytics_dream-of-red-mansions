library(word2vec)

# 訓練 word2vec 模型
model <- word2vec(
    x = 'tokenized/tokenized_words_ckip.txt',
    dim = 768,
    iter = 20,
    threads = parallel::detectCores())

# 建立放置模型的資料夾
dir.create('models', recursive = TRUE, showWarnings = FALSE)

# 儲存模型
word2vec::write.word2vec(
    x = model,
    file = "models/word2vec_ckip.bin")
