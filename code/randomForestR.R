library(randomForest)
library(caret)
library(pROC)
library(dplyr)
library(ggplot2)
library(plotly)

# Parse command-line arguments
args <- commandArgs(trailingOnly=TRUE)
if (length(args)==0) {
    stop("[USAGE] Rscript code/randomForestR.R --input data/csvfortrain/df_jieba768.csv --output results/demo/performance.csv", call.=FALSE)
}

# Parse input arguments
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
# Check input arguments
if (is.na(f_in)) {
    stop("Unable to identify input file, please use --input input.csv", call.=FALSE)
}

if (is.na(f_out)) {
    stop("Unable to identify output file, please use --output output.csv", call.=FALSE)
}
#if (!dir.exists(f_out)) {
#    dir.create(dirname(f_out), recursive = TRUE, showWarnings = FALSE)
#}

# 載入資料集
#data <- read.csv("data/csvfortrain/df_jieba768.csv")

#importance_feature <-read.csv("selected_features060250.csv")
#importance_feature_list <- as.character(importance_feature$x)

data <- read.csv(f_in)

# 添加標籤欄位
data$new_label <- "0"
data$new_label[1:80] <- "1"


# 設定種子以確保結果的可重現性
set.seed(123)

# 將資料集打亂順序
data <- data[sample(nrow(data)), ]

# 分割資料集
train_size <- round(0.8 * nrow(data))
test_size <- nrow(data) - train_size

train_data <- data[1:train_size, 2:769] 
#train_data <- data[1:train_size, importance_feature_list]
train_labels <- data[1:train_size, 770]

test_data <- data[(train_size + 1):(train_size + test_size), 2:769]
#test_data <- data[(train_size + 1):(train_size + test_size), importance_feature_list]
test_labels <- data[(train_size + 1):(train_size + test_size), 770]

# 正規化處理
#preprocess_params <- preProcess(train_data, method = c("center", "scale"))
#train_data <- predict(preprocess_params, train_data)
#test_data <- predict(preprocess_params, test_data)

# train_labels 是文字型態，使用 factor() 函數將其轉換為因子型態：
train_labels <- factor(train_labels)

# 建立交叉驗證設定
ctrl <- trainControl(method = "cv", number = 5)

# 建立隨機森林模型
model <- randomForest(x = train_data, y = train_labels, ntree = 100, mtry = 28, trControl = ctrl)


# 預測訓練集
train_pred <- predict(model, train_data)

# NULL model預測訓練集
#train_pred <- rep("1", length(train_labels))

# 計算訓練集上的準確率
train_accuracy <- sum(train_labels == train_pred) / length(train_labels)
cat("Training accuracy:", train_accuracy, "\n")

# 預測測試集
test_pred <- predict(model, test_data)

# NULL model 預測測試集
#test_pred <- rep("1", length(test_labels))

# 計算測試集上的準確率
test_accuracy <- sum(test_labels == test_pred) / length(test_labels)
cat("Test accuracy:", test_accuracy, "\n")

# 計算混淆矩陣
confusion <- table(test_labels, test_pred)

# 計算精確率、召回率和F1 score
precision <- confusion[2, 2] / sum(confusion[, 2])
recall <- confusion[2, 2] / sum(confusion[2, ])
f1_score <- 2 * precision * recall / (precision + recall)

cat("Precision:", precision, "\n")
cat("Recall:", recall, "\n")
cat("F1 Score:", f1_score, "\n")

# 輸出混淆矩陣
cat("Confusion Matrix:\n")
print(confusion)

#將字串型別的類別標籤轉換為數值型別：
test_pred <- as.numeric(test_pred)


# 計算AUC
roc_info <- roc(test_labels, test_pred)
auc_value <- auc(roc_info)
cat("AUC:", auc_value, "\n")

# 將結果寫入CSV檔案
performance <- data.frame(
    Train_Accuracy = train_accuracy,
    Test_Accuracy = test_accuracy,
    Precision = precision,
    Recall = recall,
    F1_Score = f1_score,
    AUC = auc_value
)

write.table(performance, file = f_out, sep = ",", row.names = FALSE)
# 輸出混淆矩陣
write.csv(confusion, file = "results/demo/confusion_matrix.csv")
# 將圖形輸出為 PDF 檔案
pdf("results/demo/roc_curve.pdf")
plot(roc_info, main = "ROC Curve", xlab = "False Positive Rate", ylab = "True Positive Rate")
dev.off()



# 繪製ROC曲線
#plot(roc_info, main = "ROC Curve", xlab = "False Positive Rate", ylab = "True Positive Rate")


# 將 train_data 和 test_data 做 PCA 轉換
pca_train <- prcomp(train_data, center = TRUE, scale. = TRUE)
pca_test <- predict(pca_train, newdata = test_data)

# 取前 3 個主成分
train_data_pca <- as.data.frame(pca_train$x[, 1:3])
test_data_pca <- as.data.frame(pca_test[, 1:3])

# 2D 圖形
data_pca_2d <- bind_cols(test_data_pca, label = as.factor(test_labels))
#ggplot(data_pca_2d, aes(x = PC1, y = PC2, color = label)) +
#  geom_point() +
#  ggtitle("2D PCA Plot")

# 將圖形輸出為 PDF 檔案
ggsave("results/demo/2d_pca_plot.pdf", plot = ggplot(data_pca_2d, aes(x = PC1, y = PC2, color = label)) + geom_point() + ggtitle("2D PCA Plot"))

# 3D 圖形
data_pca_3d <- bind_cols(test_data_pca, label = as.factor(test_labels))
#plot_ly(data = data_pca_3d, x = ~PC1, y = ~PC2, z = ~PC3, color = ~label) %>%
#  add_markers() %>%
#  layout(scene = list(xaxis = list(title = "PC1"),
#                      yaxis = list(title = "PC2"),
#                      zaxis = list(title = "PC3")),
#         title = "3D PCA Plot")

# 將圖形輸出為 HTML 檔案（互動式 3D 圖形）
# 將圖形輸出為HTML檔案
htmlwidgets::saveWidget(
    plot_ly(data = data_pca_3d, x = ~PC1, y = ~PC2, z = ~PC3, color = ~label) %>%
        add_markers() %>%
        layout(scene = list(xaxis = list(title = "PC1"),
                            yaxis = list(title = "PC2"),
                            zaxis = list(title = "PC3")),
               title = "3D PCA Plot"),
    file = "results/demo/3d_pca_plot.html"
)
# 獲得特徵重要性
#feature_importance <- importance(model)
# 按照特徵重要性由大到小的順序排序
#sorted_features <- feature_importance[order(-feature_importance), ]
# 印出特徵重要性
#print(sorted_features)
#取值>0.2
#selected_features <- names(sorted_features[sorted_features > 0.1])
#print(selected_features)
#取前100個排序過後的特徵
#selected100_features <- names(sorted_features[1:50])
#print(selected100_features)
# 將 selected_features 輸出至 CSV 檔案
#write.csv(selected100_features, file = "selected_features060250.csv", row.names = FALSE)

