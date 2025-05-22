#!/bin/bash

set -e

# 2. 运行主脚本
bash ./mp4-obfuscator.sh

# 3. 检查 comment 字段
comment=$(AtomicParsley test.mp4 -t 2>/dev/null | grep -E '©cmt|comment' | awk -F': ' '{print $2}')

if [ -n "$comment" ]; then
    echo "✅ 测试通过，comment 字段为: $comment"
    result=0
else
    echo "❌ 测试失败，未找到 comment 字段"
    result=1
fi

exit $result
