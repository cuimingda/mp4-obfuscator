
#!/bin/bash

# 记录开始时间
start_time=$(date +"%Y-%m-%d %H:%M:%S")
start_ts=$(date +%s)

# 检查是否安装了 AtomicParsley
if ! command -v AtomicParsley &>/dev/null; then
    echo "❌ AtomicParsley 未安装，请先安装后再运行。"
    exit 1
fi

if ! command -v ffmpeg &>/dev/null; then
    echo "❌ ffmpeg 未安装，请先安装后再运行。"
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

total_files=0
success_files=0

# 遍历当前目录下所有 .mp4 文件
for filepath in ./*.mp4; do

    # 检查文件是否存在（防止没有匹配文件时的问题）
    [ -f "$filepath" ] || continue
    total_files=$((total_files + 1))

    # 单文件处理开始时间
    file_start_time=$(date +"%Y-%m-%d %H:%M:%S")
    file_start_ts=$(date +%s)

    # 输出原始文件路径
    echo "[调试] 原始文件路径: $filepath"

    # 提取文件名
    file=$(basename "$filepath")
    # 输出提取后的文件名
    echo "[调试] 提取后的文件名: $file"

    # 先用 ffmpeg 重新封装，确保 mp4 结构无问题

    cleaned_tmpfile="${file%.mp4}_cleaned.mp4"
    echo "[调试] 即将执行: ffmpeg -i '$file' -c copy -movflags faststart '$cleaned_tmpfile' -y -loglevel error"
    ffmpeg -i "$file" -c copy -movflags faststart "$cleaned_tmpfile" -y -loglevel error
    if [ ! -f "$cleaned_tmpfile" ]; then
        echo "❌ $file ffmpeg 封装失败，跳过此文件"
        continue
    fi
    mv "$cleaned_tmpfile" "$file"

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
        success_files=$((success_files + 1))
    else
        echo "❌ 失败：$file 未能成功生成新文件"
    fi

    # 单文件处理结束时间
    file_end_time=$(date +"%Y-%m-%d %H:%M:%S")
    file_end_ts=$(date +%s)
    file_duration=$((file_end_ts - file_start_ts))
    echo "⏱️ [统计] $file 开始: $file_start_time  结束: $file_end_time  用时: ${file_duration} 秒"
done

# 记录结束时间
end_time=$(date +"%Y-%m-%d %H:%M:%S")
end_ts=$(date +%s)
duration=$((end_ts - start_ts))

echo "\n📊🕒 ========== 汇总统计 =========="
echo "🟢 开始时间: $start_time"
echo "🔴 结束时间: $end_time"
echo "⏳ 总用时: ${duration} 秒"
echo "📦 总文件数: $total_files"
echo "✅ 成功处理: $success_files"
