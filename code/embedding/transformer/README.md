# 使用 huggingface 的 transformer model
目前使用 BERT 的 bert-base-chinese 模型

## 安裝套件
在 Anaconda 環境中安裝:
```
# CPU-only
pip install torch torchvision torchaudio
pip install transformers
```

之後到 R 專案環境:
```
# 讓 R 可以使用 Python
install.packages("reticulate")
```