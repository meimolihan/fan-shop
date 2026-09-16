修复移植机 Docker 重启后「容器管理」页面空白的问题：通过DOCKER_HOST环境变量改走/:/host目录树挂载下的实时套接字路径，杜绝bind-mount套接字文件变陈旧。
