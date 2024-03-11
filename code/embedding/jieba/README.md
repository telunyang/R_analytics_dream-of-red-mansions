# 透過 jieba 建立 embedding

## 安裝套件
```
# jiebaR 結巴
install.packages("jiebaR")

# word2vec
install.packages("word2vec")
```

## 程式說明
- json2token.R: 使用 jieba 建立斷詞，存在 tokenized 資料夾
- train_word2vec.R: 將 tokenized/tokenized_jieba.txt 讀出來後，進行建模
- doc2vec.R: 將每一回文章斷詞後，整合 word2vec 模型建立 embedding