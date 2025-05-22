#!/bin/bash

# 检查是否安装了 AtomicParsley
if ! command -v AtomicParsley &>/dev/null; then
    echo "❌ AtomicParsley 未安装，请先安装后再运行。"
    exit 1
fi

# 检查是否安装了 uuidgen
if ! command -v uuidgen &>/dev/null; then
    echo "❌ uuidgen 未安装，请先安装后再运行。"
    exit 1
fi

# 判断当前目录下是否有 mp4 文件
mp4_count=$(find . -maxdepth 1 -name '*.mp4' | wc -l)
if [ "$mp4_count" -eq 0 ]; then
    echo "⚠️ 当前目录下未找到任何 mp4 文件。"
    exit 0
fi

# 遍历当前目录下所有 .mp4 文件
find . -maxdepth 1 -name '*.mp4' -print0 | \
    while IFS= read -r -d '' file; do
    # 去掉前缀 ./
    file=${file#./}

    # 生成一个随机 UUID 作为 comment 内容
    rand_comment=$(uuidgen)

    # 创建临时文件名
    tmpfile="${file%.mp4}_tmp.mp4"

    echo "🔧 正在处理：$file"
    echo "   写入 comment: $rand_comment"

    # 写入 comment 字段
    AtomicParsley "$file" \
        --comment "$rand_comment" \
        -o "$tmpfile" >/dev/null 2>&1

    # 检查是否成功生成临时文件，并覆盖原文件
    if [ -f "$tmpfile" ]; then
        mv "$tmpfile" "$file"
        echo "✅ 完成：$file 已修改并覆盖"
    else
        echo "❌ 失败：$file 未能成功生成新文件"
    fi
done
