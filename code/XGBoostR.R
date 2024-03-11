library(xgboost)
library(caret)
library(pROC)

# 載入資料集
data <- read.csv("data/csvfortrain/df_jieba768.csv")

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

train_labels <- data[1:train_size, 770]

test_data <- data[(train_size + 1):(train_size + test_size), 2:769]

test_labels <- data[(train_size + 1):(train_size + test_size), 770]

# 將類別標籤轉換為數值型別
train_labels <- as.numeric(train_labels)
test_labels <- as.numeric(test_labels)

# 轉換資料為DMatrix格式
train_dmatrix <- xgb.DMatrix(data = as.matrix(train_data), label = train_labels)
test_dmatrix <- xgb.DMatrix(data = as.matrix(test_data), label = test_labels)

# 設定XGBoost參數
params <- list(
  objective = "binary:logistic",
  eta = 0.1,
  max_depth = 6,
  subsample = 0.8,
  colsample_bytree = 0.8
)

# 訓練XGBoost模型
model <- xgboost(params = params, data = train_dmatrix, nrounds = 100)

# 預測訓練集
train_pred <- predict(model, train_dmatrix)

# 計算訓練集上的準確率
train_accuracy <- sum(train_labels == round(train_pred)) / length(train_labels)
cat("Training accuracy:", train_accuracy, "\n")

# 預測測試集
test_pred <- predict(model, test_dmatrix)

# 計算測試集上的準確率
test_accuracy <- sum(test_labels == round(test_pred)) / length(test_labels)
cat("Test accuracy:", test_accuracy, "\n")

# 計算混淆矩陣
confusion <- table(test_labels, round(test_pred))

# 計算精確率、召回率和F1 score
precision <- confusion[2, 2] / sum(confusion[, 2])
recall <- confusion[2, 2] / sum(confusion[2, ])
f1_score <- 2 * precision * recall / (precision + recall)

cat("Precision:", precision, "\n")
cat("Recall:", recall, "\n")
cat("F1 Score:", f1_score, "\n")

# 計算AUC
roc_info <- roc(test_labels, test_pred)
auc_value <- auc(roc_info)
cat("AUC:", auc_value, "\n")

# 繪製ROC曲線
plot(roc_info, main = "ROC Curve", xlab = "False Positive Rate", ylab = "True Positive Rate")

