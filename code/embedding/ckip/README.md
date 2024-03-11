# 透過 ckiptagger 建立 embedding

## 安裝套件
先切換到 Anaconda 環境，再安裝 ckiptagger 套件:
```
# 最小安裝
pip install ckiptagger
```

之後到 R 專案環境:
```
# 讓 R 可以使用 Python
install.packages("reticulate")
```

在 R 當中使用 Python 虛擬環境:
```
# 指定 conda 環境 (下面是 Windows 路徑)
use_condaenv("C:\\Users\\darren\\anaconda3\\envs\\da", required=TRUE)

# 匯入 ckiptagger 套件
ckiptagger <- import("ckiptagger")

# 下載模型包 (尚未下載的話，可以執行這段程式碼，下載完建議註解，以免重複下載)
ckiptagger$data_utils$download_data_gdown("./")
```

## 程式說明
- json2token.R: 使用 ckiptagger 建立斷詞，存在 tokenized 資料夾
- train_word2vec.R: 將 tokenized/tokenized_ckip.txt 讀出來後，進行建模
- doc2vec.R: 將每一回文章斷詞後，整合 word2vec 模型建立 embedding

## 下載中研院模型包 (Optional)
- [iis-ckip](http://ckip.iis.sinica.edu.tw/data/ckiptagger/data.zip)
- [gdrive-ckip](https://drive.google.com/drive/folders/105IKCb88evUyLKlLondvDBoh7Dy_I1tm)
- [gdrive-jacobvsdanniel](https://drive.google.com/drive/folders/15BDjL2IaX3eYdFVzT422VwCb743Hrbi3)

## 參考連結
- [ckiplab/ckiptagger](https://github.com/ckiplab/ckiptagger/wiki/Chinese-README)
