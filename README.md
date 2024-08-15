# walle_cli_channle
### 基于美团的 walle 对 APK 进行多渠道打包，并且签名。签名基于 android sdk apksigner

## Walle 分发
> [walle-cli 文档](https://github.com/Meituan-Dianping/walle/blob/master/walle-cli/README.md)。
> 
> [walle_channle_cli.jar 下载地址](https://github.com/Meituan-Dianping/walle/releases)。

### walle 打包一个渠道
java -jar 【walle-cli-all.jar 路径】 put -c 【渠道名称】 【需要打包的apk文件】

```
//示例：

//进入 walle_channle_cli 目录
cd walle_channle_cli   

//打包小米渠道
java -jar signer/walle-cli-all.jar put -c xiaomi app-release.apk
//打包小米渠道，并且指定输出文件名称
java -jar signer/walle-cli-all.jar put -c xiaomi app-release.apk app-release-xiaomi.apk

//验证APK渠道
java -jar signer/walle-cli-all.jar show app-release-xiaomi.apk
```

### walle 打包多个渠道
java -jar 【walle-cli-all.jar 路径】 put -c 【渠道名称1,渠道名称2】 【需要打包的apk文件】

```
//示例：
//进入 walle_channle_cli 目录
cd walle_channle_cli   

//打包多个渠道
java -jar signer/walle-cli-all.jar batch -c xiaomi,huawei,oppo,vivo app-release.apk

//验证APK渠道
java -jar signer/walle-cli-all.jar show app-release_xiaomi.apk
java -jar signer/walle-cli-all.jar show app-release_huawei.apk
...

```

### walle 指定渠道配置文件打包多个APK
java -jar 【walle-cli-all.jar 路径】 batch -f 【渠道文件名称】 【需要打包的apk文件】

```
//示例：
//进入 walle_channle_cli 目录
cd walle_channle_cli   

//打包多个渠道
java -jar signer/walle-cli-all.jar batch -f signer/channel app-release.apk

//验证APK渠道
java -jar signer/walle-cli-all.jar show app-release_xiaomi.apk
java -jar signer/walle-cli-all.jar show app-release_signed_huawei.apk
...

```

### walle 渠道文件多个APK，指定一个输出目录

```
//没找到知道输出目录的命令，这里我们命令行自己创建一个字目录
mkdir -p output_apks
//然后把分发渠道的apk都移动到 output_apks/ 下
mv hlyd-*-release_*.apk output_apks/
//到这里，渠道分发就完成了
```

## apksigner 签名：使用 androidStudio SDK apksigner 进行签名

### 如果没有配置 apksigner 环境变量，需要先配置

```
//这里提供MAC上配置环境变量的方法
1. 命令行：open ~/.bash_profile 打开文件添加如下两行
2. export ANDROID_HOME=$HOME/Library/Android/sdk
3. export PATH=$PATH:$ANDROID_HOME/build-tools/34.0.0
4. 进入 sdk/build-tools/ 下看看build-tools有哪些版本，配置最新的版本就行
5. 修改后保存文件，命令行执行 source ~/.bash_profile，或者重启终端
6. 输入 apksigner --version 验证
```

### apksigner 签名
apksigner sign --ks 【签名文件】 \   
--ks-key-alias 【KEY_ALIAS】 \
--ks-pass pass:【STORE_PASSWORD】 \
--key-pass pass:【KEY_PASSWORD】  \
--v1-signing-enabled true \        # 支持V1签名（新版SDK不支持）
--v2-signing-enabled true \        # 支持V2签名
--v3-signing-enabled true \        # 支持V3签名
--v4-signing-enabled true \        # 支持V4签名（未生效）
--out 【签名后的APK文件】 【签名前的APK文件】

```
//示例
apksigner sign --ks signer/debug.keystore \
   --ks-key-alias debug_key \
   --ks-pass pass:123456 \
   --key-pass pass:123456 \
   --v1-signing-enabled true \
   --v2-signing-enabled true \
   --v3-signing-enabled true \
   --v4-signing-enabled true \
   --out app-release-signed.apk  app-release.apk 
```


### 验证/获取 APK签名信息

```
apksigner verify --verbose --print-certs  app-release_signed.apk
```

```
apksigner sign --ks 【签名文件】 \
   --ks-key-alias 【KEY_ALIAS】 \
   --ks-pass pass:【STORE_PASSWORD】 \
   --key-pass pass:【KEY_PASSWORD】  \
   --v1-signing-enabled true \
   --v2-signing-enabled true \
   --v3-signing-enabled true \
   --v4-signing-enabled true \
   --out 【签名后的APK文件】 【签名前的APK文件】
```

### 一键签名及渠道分发脚本如下，可以将下列代码直接保存成 .sh 文件，记得替换签名文件及秘钥密码

```

# 密钥库信息
KEYSTORE_PATH="signer/debug.keystore"     # 替换为你的 keystore 文件路径
KEY_ALIAS="debug_key"                     # 替换为你的密钥别名
STORE_PASSWORD="123456"                   # 替换为你的密钥库密码
KEY_PASSWORD="123456"                     # 替换为你的密钥库密码

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

# 渠道分发
java -jar signer/walle-cli-all.jar batch -f signer/channel "$SIGNED_APK"

# 创建输出目录
OUTPUT_DIR="output_apks"
mkdir -p "$OUTPUT_DIR"

# 将输出的渠道包移动到输出目录
mv $(basename "$APK_PATH" .apk)_signed_*.apk "$OUTPUT_DIR/"

echo "All APK files have been signed and moved to $OUTPUT_DIR"

```


### mac电脑 中可能需要添加脚本执行权限 
chmod u+x 【.sh 文件路径】

```
//例如
//获取 .sh 执行权限 （只需要执行一次）
chmod u+x ./cli_channel_apk.sh 
//运行 .sh 脚本
./cli_channel_apk.sh
```


### 读取渠道名称
在位于项目的根目录 build.gradle 文件中添加Walle Gradle插件的依赖， 如下：
```
//支持 gradle 7.0
buildscript {
    dependencies {
        classpath 'com.github.Petterpx.walle:plugin:1.0.5'
    }
}
```
并在当前App的 build.gradle 文件中apply这个插件，并添加上用于读取渠道号的AAR
```
//支持 gradle 7.0
dependencies {
    implementation 'com.github.Petterpx.walle:library:1.0.5'
}
```
代码中获取渠道名称
```
String channel = WalleChannelReader.getChannel(this.getApplicationContext());
```
