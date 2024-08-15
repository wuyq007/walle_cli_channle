#!/bin/bash
# 检查是否提供了APK文件
if [ -z "$1" ]; then
    # 查找当前目录下的第一个APK文件
    APK_PATH=$(find . -maxdepth 1 -name "*.apk" | head -n 1)
    if [ -z "$APK_PATH" ]; then
        echo "未找到任何APK文件，请提供APK文件路径。"
        exit 1
    fi
    echo "未提供APK文件路径，使用当前目录下的APK文件: $APK_PATH"
else
    # 获取传入的APK文件路径
    APK_PATH=$1
fi

# 密钥库信息
KEYSTORE_PATH="signer/debug.keystore"     # 替换为你的 keystore 文件路径
KEY_ALIAS="debug_key"                     # 替换为你的密钥别名
STORE_PASSWORD="123456"                   # 替换为你的密钥库密码
KEY_PASSWORD="123456"                     # 替换为你的密钥库密码

SIGNED_APK="$(basename "$APK_PATH" .apk)_signed.apk"

# 密钥库信息
apksigner sign --ks "$KEYSTORE_PATH" \
   --ks-key-alias "$KEY_ALIAS" \
   --ks-pass pass:"$STORE_PASSWORD" \
   --key-pass pass:"$KEY_PASSWORD" \
   --v1-signing-enabled true \
   --v2-signing-enabled true \
   --v3-signing-enabled true \
   --v4-signing-enabled true \
   --out "$SIGNED_APK" "$APK_PATH"

# 删除 .idsig 文件
find . -name "*.idsig" -type f -delete

# 创建输出目录
OUTPUT_DIR="output_apks"
mkdir -p "$OUTPUT_DIR"

# 渠道分发
java -jar signer/walle-cli-all.jar batch -f signer/channel "$SIGNED_APK"

# 拷贝过去
mv $(basename "$APK_PATH" .apk)_signed_*.apk "$OUTPUT_DIR/"

echo "All APK files have been signed and moved to $OUTPUT_DIR"