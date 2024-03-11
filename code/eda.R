# install.packages("jsonlite")

library(jsonlite)
library(purrr)
library(dplyr)
library(stringr)

file_path <- "/home/arden/Documents/gdrive/r_hw/nccudsFinal/dataset/version_1.json"
chapter <- jsonlite::fromJSON(file_path)


# 文章長度
calculate_chapter_length <- function(chapter) {
    result_df <- data.frame(chapter_number = integer(),
                            nchar = integer(),
                            stringsAsFactors = FALSE)

    # Iterate over the chapters and calculate the length of each chapter
    for (i in 1:length(chapter)) {
        chapter_length <- nchar(chapter[[i]])

        # Create a new row for the chapter in the data frame
        chapter_row <- data.frame(chapter_number = i, nchar = chapter_length)

        # Append the row to the result data frame
        result_df <- rbind(result_df, chapter_row)
    }

    # Return the resulting data frame
    return(result_df)
}

chapter_length_df <- calculate_chapter_length(chapter)

#句子統計特徵 :字數統計

calculate_sentence_count <- function(chapter, split_by = "！|？|。") {
    df <- data.frame(chapter_number = integer(),
                     sentence_length = integer(),
                     stringsAsFactors = FALSE)

    for (i in 1:length(chapter)) {
        sentence <- strsplit(chapter[[i]], "！|？|。")[[1]]
        chapter_df <- data.frame(chapter_number = i,
                                 sentence_length = length(sentence),
                                 stringsAsFactors = FALSE)

        df <- rbind(df, chapter_df)
    }
    return(df)
}

sentence_count_df <- calculate_sentence_count(chapter, "！|？|。")

#句子統計特徵  : min, mean, median, max
get_stats_df <- function(chapter) {

    split_to_sentence <- function(chapter, split_by) {
        sentence_list <- list()
        for (i in 1:length(chapter)) {
            sentence_list[[i]] <- strsplit(chapter[[i]], split_by)[[1]]
        }
        return(sentence_list)
    }

    sentence_list <- split_to_sentence(chapter, "！|？|。")

    # 定義一個函數來計算文本的字符數量
    count_characters <- function(text) {
        nchar(text)
    }

    # 對每一個list中的句子進行操作
    sentence_stats <- function(sentence_list) {
        sentence_counts <- map_dbl(sentence_list, count_characters)

        list(
            min = min(sentence_counts, na.rm = TRUE),
            mean = mean(sentence_counts, na.rm = TRUE),
            median = median(sentence_counts, na.rm = TRUE),
            max = max(sentence_counts, na.rm = TRUE)
        )
    }

    # 對每一個list進行操作，然後將結果綁定到一個data.frame
    stats_df <- map_df(sentence_list, sentence_stats, .id = "chapter_number")

    # 將chapter_number 轉換為數字
    stats_df$chapter_number <- as.numeric(stats_df$chapter_number)


    write.csv(stats_df, file = "./output/status.csv", row.names = FALSE)

    return(stats_df)
}

stats_df <- get_stats_df(chapter)
stats_df

#符號統計 ：「」！？。 newline space
calculate_apostrophe <- function(chapter) {
    apostrophe_to_count <- list()
    apostrophe_to_count[["："]] = 'colon'
    apostrophe_to_count[["「"]] = 'quote_start'
    apostrophe_to_count[["」"]] = 'quote_end'
    apostrophe_to_count[["！"]] = 'excitement'
    apostrophe_to_count[["？"]] = 'question_mark'
    apostrophe_to_count[["，"]] = 'comma'
    apostrophe_to_count[["。"]] = 'period'
    apostrophe_to_count[["\n\n"]] = 'newline'


    # 計算每個特殊字元在每個章節中出現的次數
    count_apostrophe <- function(chapter, apostrophe, apostrophe_name) {
        df <- data.frame(chapter_number = 1:length(chapter))
        df[[apostrophe_name]] <- sapply(chapter, function(x) { str_count(x, fixed(apostrophe)) })
        return(df)
    }

    count_apostrophe_df <- data.frame(chapter_number = integer(0))

    # iterate 每個特殊字元並計算其在每個章節中出現的次數
    for (apostrophe in names(apostrophe_to_count)) {
        apostrophe_name <- apostrophe_to_count[[apostrophe]]
        df <- count_apostrophe(chapter, apostrophe, apostrophe_name)
        count_apostrophe_df <- full_join(count_apostrophe_df, df, by = "chapter_number")
    }

    return(count_apostrophe_df)
}


count_apostrophe_df <- calculate_apostrophe(chapter)


merged_df <- merge(chapter_length_df, sentence_count_df, by = "chapter_number")
merged_df <- merge(stats_df, merged_df, by = "chapter_number")
merged_df <-  merge(merged_df, count_apostrophe_df, by = "chapter_number")
merged_df

write.csv(merged_df, "./output/eda_result.csv")

