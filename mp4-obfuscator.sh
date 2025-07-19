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

mp4_files=()
while IFS= read -r filepath; do
    file=$(basename "$filepath")
    mp4_files+=("$file")
done < <(find . -maxdepth 1 -name '*.mp4' -type f | sort)

if [ ${#mp4_files[@]} -eq 0 ]; then
    echo "⚠️ 当前目录下未找到任何 mp4 文件。"
    exit 0
fi

total_files=0
success_files=0

# 遍历 mp4 文件数组
for file in "${mp4_files[@]}"; do

    total_files=$((total_files + 1))
    echo "========== $((total_files))/${#mp4_files[@]} => $file  =========="

    file_start_time=$(date +"%Y-%m-%d %H:%M:%S")
    file_start_ts=$(date +%s)

    tempfile=$(mktemp $TMPDIR/$(uuidgen).mp4)

    echo "🔧 ffmpeg 执行中..."
    ffmpeg \
        -i "$file" \
        -c copy \
        -movflags faststart \
        -y \
        -loglevel error \
        "$tempfile"

    if [ ! -f "$tempfile" ] || [ ! -s "$tempfile" ]; then
        echo "❌ ffmpeg 执行失败，跳过此文件"
        continue
    fi

    mv "$tempfile" "$file"
    echo "✅ ffmpeg 执行成功"

    # 生成一个随机 UUID 作为 comment 内容
    rand_comment=$(uuidgen)

    # 创建临时文件名
    tempfile=$(mktemp $TMPDIR/$(uuidgen).mp4)

    echo "🔧 正在填充comment: $rand_comment"
    AtomicParsley "$file" \
        -o "$tempfile" \
        --comment "$rand_comment" \
        >/dev/null 2>&1

    if [ ! -f "$tempfile" ] || [ ! -s "$tempfile" ]; then
        echo "❌ AtomicParsley 执行失败，跳过此文件"
        continue
    fi

    mv "$tempfile" "$file"
    echo "✅ AtomicParsley 执行成功"
    
    file_end_time=$(date +"%Y-%m-%d %H:%M:%S")
    file_end_ts=$(date +%s)
    file_duration=$((file_end_ts - file_start_ts))

    echo "⏱️ 开始时间: $file_start_time"
    echo "⏱️ 结束时间: $file_end_time"
    echo "⏳ 用时: ${file_duration} 秒"

    success_files=$((success_files + 1))
done

end_time=$(date +"%Y-%m-%d %H:%M:%S")
end_ts=$(date +%s)
duration=$((end_ts - start_ts))

echo "========== 汇总统计 =========="
echo "⏱️ 总开始时间: $start_time"
echo "⏱️ 总结束时间: $end_time"
echo "⏳ 总用时: ${duration} 秒"
echo "📦 总文件数: $total_files"
echo "✅ 成功处理: $success_files"
