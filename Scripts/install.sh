#!/bin/bash

print_box() {
    local title="$1"
    echo "========================================"
    echo "          $title"
    echo "========================================"
}

clear
print_box "双栈工坊商店 - 安装向导"
echo "1、飞牛Nas（fnOS）"
echo "2、绿联Nas（Ugreen）"
echo "3、极空间Nas"
echo -e "\n请输入选项 [1 或 2 或 3] : "
read nas_choose

clear

if [ "$nas_choose" = "1" ];then
    print_box "已选择：飞牛Nas（fnOS）"
    vol_list=($(find / -maxdepth 1 -type d -regextype posix-extended -regex '^/vol[0-9]$' 2>/dev/null))
    if [ ${#vol_list[@]} -eq 0 ];then
        echo "错误：未扫描到 /vol1‑/vol9 存储空间目录！"
        exit 1
    fi
    echo ""
    print_box "检测到以下存储空间"
    for i in "${!vol_list[@]}"; do
        index=$((i+1))
        echo "  $index) ${vol_list[$i]}"
    done
    echo -e "\n请输入存储分区序号:"
    read sel_num
    clear
    total=${#vol_list[@]}
    if ! [[ "$sel_num" =~ ^[0-9]+$ ]]; then
        echo "输入不是数字，程序退出"
        exit 1
    fi
    if [ "$sel_num" -lt 1 ] || [ "$sel_num" -gt "$total" ];then
        echo "选择超出可选范围，程序退出"
        exit 1
    fi
    install_path=${vol_list[$((sel_num-1))]}
    print_box "选定存储信息"
    echo "存储根目录: $install_path"
    echo -e "\n回车代表第1个用户，不是则输入您是第几个用户:"
    read user_index
    clear
    if [ -z "$user_index" ];then
        user_index=1
    fi
    if ! [[ "$user_index" =~ ^[1-9][0-9]*$ ]]; then
        echo "输入错误！用户序号必须为大于0的数字，程序退出"
        exit 1
    fi
    uid_num=$(( 1000 + user_index - 1 ))
    full_path="${install_path}/${uid_num}/Docker"
    shop_data_path="${full_path}/doublestack-shop"
    print_box "生成目录信息"
    echo "用户序号：$user_index"
    echo "Docker目录路径：$full_path"
    echo "项目数据目录：$shop_data_path"
    if [ -d "$full_path" ]; then
        echo "Docker目录已存在，跳过创建"
    else
        echo "Docker目录不存在，开始创建"
        mkdir -p "$full_path"
        echo "目录创建完成: $full_path"
    fi
    sleep 1
    clear
    cd "$full_path"
    compose_url="https://raw.githubusercontent.com/Double-Stack-Workshop/doublestack-shop/main/docker-compose.yml"
    print_box "正在下载配置文件"
    echo "正在下载 docker‑compose.yml ..."
    curl -fsSL "$compose_url" -o docker-compose.yml
    if [ ! -f "docker-compose.yml" ];then
        echo "错误：配置文件下载失败！程序退出"
        exit 1
    fi
    sed -i "s|./backend/|${shop_data_path}/|g" docker-compose.yml
    echo -e "\n请输入宿主机访问端口（默认8000）:"
    read host_port
    if [ -z "$host_port" ]; then
        host_port=8000
    fi
    if ! [[ "$host_port" =~ ^[0-9]+$ ]]; then
        echo "端口必须为数字，使用默认8000"
        host_port=8000
    fi
    sed -i "s|8000:8001|${host_port}:8001|g" docker-compose.yml
    echo "已设置端口映射：${host_port}:8001"
    sleep 1
    clear
    print_box "安装完成"
    echo "docker‑compose.yml存放目录: ${full_path}"
    echo "项目数据存放目录: ${shop_data_path}"
    echo -e "\n正在启动项目..."
    cd "${full_path}" && docker compose up -d

elif [ "$nas_choose" = "2" ];then
    print_box "已选择：绿联Nas（Ugreen）"
    echo "1、个人空间"
    echo "2、公共空间"
    echo -e "\n请选择存储空间类型 [1 或 2]:"
    read ug_space
    clear
    if [ "$ug_space" = "1" ];then
        print_box "个人空间模式"
        echo "请输入绿联用户名:"
        read ug_username
        clear
        if [ -z "$ug_username" ];then
            echo "用户名不能为空，程序退出"
            exit 1
        fi
        full_path="/volume1/@home/${ug_username}/Docker"
    elif [ "$ug_space" = "2" ];then
        full_path="/volume1/Docker"
    else
        echo "输入无效，程序退出"
        exit 1
    fi
    shop_data_path="${full_path}/doublestack-shop"
    print_box "生成目录信息"
    echo "Docker目录路径：$full_path"
    echo "项目数据目录：$shop_data_path"
    if [ -d "$full_path" ]; then
        echo "Docker目录已存在，跳过创建"
    else
        echo "Docker目录不存在，开始创建"
        mkdir -p "$full_path"
        echo "目录创建完成: $full_path"
    fi
    sleep 1
    clear
    cd "$full_path"
    compose_url="https://raw.githubusercontent.com/Double-Stack-Workshop/doublestack-shop/main/docker-compose.yml"
    print_box "正在下载配置文件"
    echo "正在下载 docker‑compose.yml ..."
    curl -fsSL "$compose_url" -o docker-compose.yml
    if [ ! -f "docker-compose.yml" ];then
        echo "错误：配置文件下载失败！程序退出"
        exit 1
    fi
    sed -i "s|./backend/|${shop_data_path}/|g" docker-compose.yml
    echo -e "\n请输入宿主机访问端口（默认8000）:"
    read host_port
    if [ -z "$host_port" ]; then
        host_port=8000
    fi
    if ! [[ "$host_port" =~ ^[0-9]+$ ]]; then
        echo "端口必须为数字，使用默认8000"
        host_port=8000
    fi
    sed -i "s|8000:8001|${host_port}:8001|g" docker-compose.yml
    echo "已设置端口映射：${host_port}:8001"
    sleep 1
    clear
    print_box "安装完成"
    echo "docker‑compose.yml存放目录: ${full_path}"
    echo "项目数据存放目录: ${shop_data_path}"
    echo -e "\n正在启动项目..."
    cd "${full_path}" && docker compose up -d

elif [ "$nas_choose" = "3" ];then
    print_box "已选择：极空间Nas"
    zs_vol_list=($(find / -maxdepth 1 -type d -regextype posix-extended -regex '^/data_[sn][0-9]{3}$' 2>/dev/null))
    if [ ${#zs_vol_list[@]} -eq 0 ];then
        echo "错误：未扫描到 /data_s001 /data_n001 存储空间目录！"
        exit 1
    fi
    echo ""
    print_box "检测到以下存储空间"
    for i in "${!zs_vol_list[@]}"; do
        index=$((i+1))
        echo "  $index) ${zs_vol_list[$i]}"
    done
    echo -e "\n请输入存储分区序号:"
    read sel_num
    clear
    total=${#zs_vol_list[@]}
    if ! [[ "$sel_num" =~ ^[0-9]+$ ]]; then
        echo "输入不是数字，程序退出"
        exit 1
    fi
    if [ "$sel_num" -lt 1 ] || [ "$sel_num" -gt "$total" ];then
        echo "选择超出可选范围，程序退出"
        exit 1
    fi
    install_path=${zs_vol_list[$((sel_num-1))]}
    print_box "选定存储信息"
    echo "存储根目录: $install_path"
    echo -e "\n请输入极空间用户名:"
    read zs_username
    clear
    if [ -z "$zs_username" ];then
        echo "用户名不能为空，程序退出"
        exit 1
    fi
    full_path="${install_path}/data/udata/real/${zs_username}/Docker"
    shop_data_path="${full_path}/doublestack-shop"
    print_box "生成目录信息"
    echo "用户名：$zs_username"
    echo "Docker目录路径：$full_path"
    echo "项目数据目录：$shop_data_path"
    if [ -d "$full_path" ]; then
        echo "Docker目录已存在，跳过创建"
    else
        echo "Docker目录不存在，开始创建"
        mkdir -p "$full_path"
        echo "目录创建完成: $full_path"
    fi
    sleep 1
    clear
    cd "$full_path"
    compose_url="https://raw.githubusercontent.com/Double-Stack-Workshop/doublestack-shop/main/docker-compose.yml"
    print_box "正在下载配置文件"
    echo "正在下载 docker‑compose.yml ..."
    curl -fsSL "$compose_url" -o docker-compose.yml
    if [ ! -f "docker-compose.yml" ];then
        echo "错误：配置文件下载失败！程序退出"
        exit 1
    fi
    sed -i "s|./backend/|${shop_data_path}/|g" docker-compose.yml
    echo -e "\n请输入宿主机访问端口（默认8000）:"
    read host_port
    if [ -z "$host_port" ]; then
        host_port=8000
    fi
    if ! [[ "$host_port" =~ ^[0-9]+$ ]]; then
        echo "端口必须为数字，使用默认8000"
        host_port=8000
    fi
    sed -i "s|8000:8001|${host_port}:8001|g" docker-compose.yml
    echo "已设置端口映射：${host_port}:8001"
    sleep 1
    clear
    print_box "安装完成"
    echo "docker‑compose.yml存放目录: ${full_path}"
    echo "项目数据存放目录: ${shop_data_path}"
    echo -e "\n正在启动项目..."
    cd "${full_path}" && docker compose up -d

else
    echo "输入无效，请重新运行脚本并选择1或者2或者3"
    exit 1
fi