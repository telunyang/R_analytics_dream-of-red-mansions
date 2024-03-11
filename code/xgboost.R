install.packages("xgboost")

# 載入所需的套件
library(xgboost)
library(FactoMineR)
library(scatterplot3d)
library(pROC)


# 讀取章節字數與標點符號的csv資料
data <- read.csv("data/eda_input.csv")
data$new_label <- "0"
data$new_label[1:80] <- "1"

# 設定種子以確保結果的可重現性
set.seed(456)

# 將資料集打亂順序
data <- data[sample(nrow(data)), ]

# 分割資料集
train_size <- round(0.8 * nrow(data))
test_size <- nrow(data) - train_size

train_data <- data[1:train_size, 3:17]
train_labels <- data[1:train_size, 18]

test_data <- data[(train_size + 1):(train_size + test_size), 3:17]
test_labels <- data[(train_size + 1):(train_size + test_size), 18]

# 將資料轉換為DMatrix格式
dtrain <- xgb.DMatrix(data = as.matrix(train_data), label = train_labels)
dtest <- xgb.DMatrix(data = as.matrix(test_data), label = test_labels)

# 設定XGBoost的參數
params <- list(
  objective = "binary:logistic",
  eval_metric = "error"
)

# 執行交叉驗證
cv_result <- xgb.cv(params = params, data = dtrain, nrounds = 100, nfold = 5)

# 查看交叉驗證結果
print(cv_result)

# 訓練XGBoost模型
model <- xgb.train(params = params, data = dtrain, nrounds = 100)

# 預測訓練集
train_predictions <- predict(model, dtrain, type = "raw")
train_predictions <- ifelse(train_predictions > 0.6, "1", "0")

# 計算準確率
train_accuracy <- sum(train_predictions == train_labels) / length(train_labels)
cat("訓練準確率:", train_accuracy, "\n")

# 預測測試集
test_predictions <- predict(model, dtest, type = "raw")
test_predictions <- ifelse(test_predictions > 0.6, "1", "0")

# 計算準確率
test_accuracy <- sum(test_predictions  == test_labels) / length(test_labels)
cat("測試準確率:", test_accuracy, "\n")

# 計算混淆矩陣
confusion <- table(test_labels, test_predictions)

# 計算精確率、召回率和F1 score
precision <- confusion[2, 2] / sum(confusion[, 2])
recall <- confusion[2, 2] / sum(confusion[2, ])
f1_score <- 2 * precision * recall / (precision + recall)

cat("Precision:", precision, "\n")
cat("Recall:", recall, "\n")
cat("F1 Score:", f1_score, "\n")

cat("Confusion Matrix:\n")
print(confusion)

#將字串型別的類別標籤轉換為數值型別：
test_predictions <- as.numeric(test_predictions)


# 計算AUC
roc_info <- roc(test_labels, test_predictions)
auc_value <- auc(roc_info)
cat("AUC:", auc_value, "\n")


df <- data.frame(train_accuracy, test_accuracy, precision,recall,f1_score,auc_value)
header <- c("train_accuracy", "test_accuracy", "precision","recall","f1_score","auc")
colnames(df) <- header
write.csv(df, file = "results/xgboost_result.csv", row.names = FALSE)

# 繪製ROC曲線
plot(roc_info, main = "ROC Curve", xlab = "False Positive Rate", ylab = "True Positive Rate")

for_pca_data <- data[, 3:17]
for_pca_labels <- data[, 18]

# 主成分分析（PCA）
pca_result <- PCA(for_pca_data, graph = FALSE)

# 提取前三個主成分
pca_data <- as.data.frame(pca_result$ind$coord[, 1:3])
pca_data$label <- as.factor(for_pca_labels)

# 繪製三維PCA圖表
s3d <- scatterplot3d(pca_data[, 1], pca_data[, 2], pca_data[, 3],
                     color = ifelse(pca_data$label == "1", "red", "blue"), pch = 16,
                     xlab = paste("PC1 (", round(pca_result$eig[1, "percentage of variance"], 2), "%)"),
                     ylab = paste("PC2 (", round(pca_result$eig[2, "percentage of variance"], 2), "%)"),
                     zlab = paste("PC3 (", round(pca_result$eig[3, "percentage of variance"], 2), "%)"),
                     main = "3D PCA Scatter Plot")

# 添加類別標籤
legend("topright", legend = levels(pca_data$label), col = c("blue", "red"), pch = 16)

