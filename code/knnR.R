library(caret)
library(pROC)

# 載入資料集
data <- read.csv("data/csvfortrain/df_jieba768.csv")
#importance_feature <-read.csv("selected_features0528.csv")
#importance_feature_list <- as.character(importance_feature$x)


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


train_labels <- factor(train_labels)
test_labels <- factor(test_labels)

# 建立交叉驗證設定
ctrl <- trainControl(method = "cv", number = 5)

# 建立KNN模型
model <- train(
  x = train_data,
  y = train_labels,
  method = "knn",
  trControl = ctrl,
  tuneLength = 10
)

# 預測訓練集
train_pred <- predict(model, train_data)

# 計算訓練集上的準確率
train_accuracy <- sum(train_labels == train_pred) / length(train_labels)
cat("Training accuracy:", train_accuracy, "\n")

# 預測測試集
test_pred <- predict(model, test_data)

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

# 計算AUC
roc_info <- roc(test_labels, test_pred)
auc_value <- auc(roc_info)
cat("AUC:", auc_value, "\n")

# 繪製ROC曲線
plot(roc_info, main = "ROC Curve", xlab = "False Positive Rate", ylab = "True Positive Rate")

# 將 train_data 和 test_data 做 PCA 轉換
pca_train <- prcomp(train_data, center = TRUE, scale. = TRUE)
pca_test <- predict(pca_train, newdata = test_data)

# 取前 3 個主成分
train_data_pca <- as.data.frame(pca_train$x[, 1:3])
test_data_pca <- as.data.frame(pca_test[, 1:3])

# 2D 圖形
data_pca_2d <- bind_cols(test_data_pca, label = as.factor(test_labels))
ggplot(data_pca_2d, aes(x = PC1, y = PC2, color = label)) +
  geom_point() +
  ggtitle("2D PCA Plot")

# 3D 圖形
data_pca_3d <- bind_cols(test_data_pca, label = as.factor(test_labels))
plot_ly(data = data_pca_3d, x = ~PC1, y = ~PC2, z = ~PC3, color = ~label) %>%
  add_markers() %>%
  layout(scene = list(xaxis = list(title = "PC1"),
                      yaxis = list(title = "PC2"),
                      zaxis = list(title = "PC3")),
         title = "3D PCA Plot")
