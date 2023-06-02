# image

这个子目录存放与镜像相关的脚本，比如私有化镜像、清理镜像等。

## 脚本列表

以下是该子目录下的脚本列表及其简要说明：

- privatize_images.sh：下载并推送指定的镜像到私有仓库，并可以根据参数控制是否删除本地镜像。

## 脚本用法

以下是每个脚本的具体用法及其参数说明：

### privatize_images.sh

该脚本可以下载并推送指定的镜像到私有仓库，并可以根据参数控制是否删除本地镜像。它支持从文件或命令行参数中读取多个待处理的镜像名，并可以指定使用docker或podman作为容器引擎。

#### 参数说明

该脚本支持以下参数：

- -c, --cmd：指定使用 `docker` 或 `podman`，默认为 `docker`。
- -r, --repo：指定私有仓库地址，默认为 `myRegistry.com`。
- -f, --file：指定镜像列表文件，每行一个镜像名。
- -i, --images：指定多个待下载的镜像，用逗号分隔。
- -d, --delete：指定是否删除镜像，默认为 `true`。
- -h, --help：显示帮助信息。

#### 使用示例

以下是一些使用示例：

- 下载并推送 registry.k8s.io/etcd:3.5.7-0 到 127.0.0.1:5000，并删除本地镜像：

```bash
./privatize_images.sh -c podman -r 127.0.0.1:5000 -i registry.k8s.io/etcd:3.5.7-0
```

下载并推送 `images.txt` 文件中列出的所有镜像到 `myRegistry.com`，并保留本地镜像：

```
./privatize_images.sh -d false -f images.txt
```

显示帮助信息：

```
./privatize_images.sh -h
```
