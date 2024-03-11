library(randomForest)
library(ggplot2)

# Parse command-line arguments
args <- commandArgs(trailingOnly=TRUE)
if (length(args)==0) {
    stop("[USAGE] Rscript code/treeDepthAndImportantFeatureR.R --input data/csvfortrain/df_jieba768.csv --output results/demo/importantFeatures.csv", call.=FALSE)
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
if (!dir.exists(f_out)) {
    dir.create(dirname(f_out), recursive = TRUE, showWarnings = FALSE)
}


# Check input arguments
if (is.na(f_in)) {
    stop("Unable to identify input file, please use --input input.csv", call.=FALSE)
}

if (is.na(f_out)) {
    stop("Unable to identify output file, please use --output output.csv", call.=FALSE)
}



set.seed(123)
#input_data <- read.csv("data/csvfortrain/df_jieba768.csv")
input_data <- read.csv(f_in)
input_data <- input_data[, -1]

#建立随机森林模型
random_forest_model <- randomForest(dim1 ~ ., 
                         data=input_data, 
                         mtry=28,
                         importance=TRUE, 
                         proximity=TRUE,
                         na.action=na.omit)

random_forest_model
plot(random_forest_model)
#importance(random_forest_model)
varImpPlot(random_forest_model)


feature_importance <- importance(random_forest_model)
#str(feature_importance)

positive_importance <- feature_importance[feature_importance[, "%IncMSE"] > 0, ]
positive_importance <- cbind(feature = rownames(positive_importance), positive_importance)
#write.csv(positive_importance, file = "positive_importance.csv", row.names = FALSE)
write.csv(positive_importance, file = f_out, row.names = FALSE)

# 產生圖形
png("results/demo/plot.jpg")
plot(random_forest_model)
dev.off()

png("results/demo/varImpPlot.jpg")
varImpPlot(random_forest_model)
dev.off()

