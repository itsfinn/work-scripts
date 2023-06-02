#!/bin/bash

# 设置默认值
CMD=docker
REPO=myRegistry.com
DELETE=true # 默认删除镜像

# 定义帮助信息
usage() {
    echo "用法："
    echo " ./privatize_images.sh [选项]"
    echo ""
    echo " -c, --cmd"
    echo " 指定使用docker或podman。"
    echo " ;;"
    echo ""
    echo " -r, --repo"
    echo " 指定私有仓库地址。"
    echo " ;;"
    echo ""
    echo " -f, --file"
    echo " 指定镜像列表文件。"
    echo " ;;"
    echo ""
    echo " -i, --images"
    echo " 指定多个待下载的镜像，用逗号分隔。"
    echo " ;;"
    echo ""
    echo " -d, --delete"
    echo " 指定是否删除镜像，默认为true。"
    echo " ;;"
    echo ""
    echo " -h, --help"
    echo " 显示帮助信息。"
    echo " ;;"
}

# 定义下载并推送单个镜像的函数
download_and_push() {
    local image=$1 # 接收第一个参数作为镜像名
    local NEW_IMAGE="" # 定义一个变量表示转换成私有仓库的镜像名

    # 下载镜像
    $CMD pull "$image"

    # 判断下载是否成功
    if [ $? -eq 0 ]; then
        # 使用参数扩展功能，以替换原始镜像名中的任何仓库地址为私有仓库地址
        # 将转换后的镜像名赋值给NEW_IMAGE变量
        NEW_IMAGE=${image/${image%%/*}/$REPO}

        # 给镜像打标签，使用私有仓库地址和原始镜像名
        $CMD tag "$image" "$NEW_IMAGE"

        # 推送到仓库
        $CMD push "$NEW_IMAGE"

        # 推送是否成功
        if [ $? -eq 0 ]; then
            echo "$NEW_IMAGE push 成功。"
        else
            echo "$NEW_IMAGE push 失败"
        fi

        # 根据DELETE变量的值决定是否删除本地镜像，节省空间
        if [ "$DELETE" = true ]; then
            $CMD rmi "$image" "$NEW_IMAGE"
        fi

        return 0
    else
        return 1
    fi
}


# 定义从文件中读取并处理多个镜像的函数
process_from_file() {
    local file=$1 # 接收第一个参数作为文件名

    # 判断文件是否存在
    if [ ! -f "$file" ]; then
        echo "$file 不是一个有效的文件。"
        exit 1
    fi

    # 遍历文件中的每一行作为image变量的值并处理
    while read image; do

        # 调用download_and_push函数，传入image作为参数
        download_and_push "$image"

        # 判断处理是否成功
        if [ $? -eq 0 ]; then
            echo "$image 处理成功。"
        else
            echo "$image 处理失败。"
        fi

    done < "$file" # 从文件中读取每一行
}

# 定义从命令行参数中读取并处理多个镜像的函数
process_from_args() {
    local images=$1 # 接收第一个参数作为包含多个镜像名的字符串# 使用readarray命令将字符串按照逗号分割成数组
    readarray -t -d ',' images <<< "$images"

    # 遍历数组中的每个元素作为image变量的值并处理
    for image in $images; do

        # 调用download_and_push函数，传入image作为参数
        download_and_push $image

        # 判断处理是否成功
        if [ $? -eq 0 ]; then
            echo "$image 处理成功。"
        else
            echo "$image 处理失败。"
        fi

    done
}

# 解析命令行参数
while [ "$#" -gt 0 ]; do
     case "$1" in # 使用双引号包裹$1
     -c|--cmd) # 指定使用docker或podman
         CMD="$2"
         shift 2
         ;;
     -r|--repo) # 指定私有仓库地址
         REPO="$2"
         shift 2
         ;;
     -f|--file) # 指定镜像列表文件
         FILE="$2"
         shift 2
         ;;
     -i|--images) # 指定多个待下载的镜像，用逗号分隔
         IMAGES="$2"
         shift 2
         ;;
     -d|--delete) # 指定是否删除镜像，默认为true
         DELETE="$2"
         shift 2
         ;;
     -h|--help) # 显示帮助信息
         usage
         exit 0
         ;;
     *) # 其他无效参数
         usage
         exit 1
         ;;
     esac
done

# 如果没有指定镜像列表文件或镜像名，退出脚本并显示帮助信息
if [ -z "$FILE" ] && [ -z "$IMAGES" ]; then
     echo "请指定一个文件或镜像来下载和推送。"
     usage
     exit
fi

# 如果指定了镜像列表文件，调用process_from_file函数，传入FILE作为参数
if [ -n "$FILE" ]; then
     process_from_file "$FILE"
fi

# 如果指定了多个待下载的镜像，调用process_from_args函数，传入IMAGES作为参数
if [ -n "$IMAGES" ]; then
     process_from_args "$IMAGES"
fi
