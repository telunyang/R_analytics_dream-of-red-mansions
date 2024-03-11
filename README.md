以前跟同學合作的一個小品，用 R 語言撰寫程式，我們當時用的方法不是很好，少數同學的參與意願也不高，不過能看到專案完成，也算有始有終。
一直歸檔放著，可能就會隨著時間過去或人為因素而消失不見，乾脆直接 Open Source。
未來有時間再重構，或是使用其它技術來重新改良。

---

# [Group 2] 紅樓夢 之 文風分析與文本分類
- 背景
  - 《紅樓夢》是古典小說中的經典之作，列為四大名著之一，是一部具有高度思想性與藝術性的文學鉅著。
  - 雖然流傳已逾兩百餘年，然而此書實際作者是誰，卻是專家們爭論的議題，一直以來都存在著爭議。
  - 1920年代開始，根據胡適先生的考證，認為小說的「前八十回」與「後四十回」並非同一人所著。
  - 在胡適先生求證之下，認為後四十回並非曹雪芹所著，並提出高鶚續書後四十回之論點。
- 動機
  - 《紅樓夢》的作者問題歷經多年的研究，但至今仍未有定論，各種說法並存，傳統的研究方法主要基於對文本的主觀判斷和考證，缺乏客觀的科學依據。
  - 隨著資料科學及深度學習技術的不斷發展，可以應用統計分析及深度學習方法，對《紅樓夢》進行深入挖掘，以期為作者問題提供一個更為客觀、科學的解答。
- 目的
  - 本研究應用統計分析方法對《紅樓夢》前八十回和後四十回的文本進行詞頻分析、詞向量分析等，以探討前八十回和後四十回之間之差異性。
  - 同時，本研究還結合深度學習方法對《紅樓夢》的進行文本分類，探討前八十回和後四十回是否由同一人所寫，嘗試透過不同的研究方法，來驗證胡適先生的考證結論。


## Contributors
|組員|系級|工作分配|
|-|-|-|
|郝　昀|資科碩二|資料前處理、資料分析|
|曾祐展|資科碩一|資料前處理、資料分析、特徵工程|
|羅延康|資科碩一|資料蒐集、資料前處理、資料分析|
|羅永傑|資科碩一|模型訓練、資料分析、成效評估|
|蔡孟宗|資科碩一|資料前處理、模型訓練、成效評估|
|楊德倫|資科碩一|企畫發想、特徵工程、錯誤分析、結論|


## Quick start
You might provide an example commend or few commends to reproduce your analysis, i.e., the following R script
```R
Rscript code/your_script.R --input data/training --output results/performance.tsv
```
Demo1 - Tree Depth & Important Features
```R
Rscript code/treeDepthAndImportantFeatureR.R --input data/csvfortrain/df_jieba768.csv --output results/demo/importantFeatures.csv
```
Demo2 - Random Forest
```R
Rscript code/randomForestR.R --input data/csvfortrain/df_jieba768.csv --output results/demo/performance.csv
```
Demo3 - pca
```R
Rscript code/pca.R --input data/csvfortrain --output results/pca
```
Demo4 - tsne
```R
Rscript code/tsne.R --input data/csvfortrain --output results/tsne
```
Demo5 - umap
```R
Rscript code/wordembeddingspace.R --input data/dataset/version_1_clean.json --output results/umap
```

## Folder organization and its related description

### docs
* 1112_DS-FP_group2.pptx

### data
* csvfortrain
* dataset
* image
* models
* tokenized
  * eda_input.csv

### code
* embedding
  * decisionTreeR.R
  * eda.R
  * jieba768_fre278.R
  * knnR.R
  * logisticRegressionR.R
  * pca.R
  * randomForestR.R
  * treeDepthAndlmportantFeatureR.R
  * tsne.R
  * wordembeddingspace.R
  * xgboost.R
  * XGBoostR.R

### results
* demo
* pca
* tsne
* umap
  * xgboost_result.csv

## References
* 語料來源
  - [紅樓夢甲版來源](http://www.speedy7.com/cn/stguru/cht/redmansions.htm)
* 參考網頁
  - [Wiki 紅樓夢](https://zh.wikipedia.org/zh-tw/紅樓夢)
  - [利用文本採礦探討《紅樓夢》的後四十回作者爭議](http://www.dadh-record.digital.ntu.edu.tw/config_xml/2012config/programINFO/abs/paper03_01_abs.pdf)
  - [淺談中文比對系統中的「文風分析」](https://lsl.sinica.edu.tw/Blog/2022/08/29-2/)
