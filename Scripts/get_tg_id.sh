#!/bin/bash

read -p "请输入你的 Telegram Bot Token: " BOT_TOKEN

if [[ -z "$BOT_TOKEN" ]]; then
    echo "❌ Token不能为空，程序退出"
    exit 1
fi

echo ""
echo "🔍 正在检测服务器能否访问 Telegram API..."
# 测试连通性，5秒超时
TEST_RESULT=$(curl -s --connect-timeout 5 "https://api.telegram.org")

if [[ -z "$TEST_RESULT" ]]; then
    echo "❌ 无法连接 Telegram API！当前服务器网络不通TG，无法获取ID"
    exit 1
fi
echo "✅ 网络检测通过，可以访问TG接口"

API_URL="https://api.telegram.org/bot${BOT_TOKEN}/getUpdates"

echo ""
echo "=============================================="
echo "  请打开TG，给你的机器人发一条任意消息"
echo "  发送完成后按回车继续..."
echo "=============================================="
read -r

RESPONSE=$(curl -s "${API_URL}")

USER_ID=$(echo "$RESPONSE" | grep -o '"id":[0-9]*' | tail -1 | cut -d: -f2)
USER_NAME=$(echo "$RESPONSE" | grep -o '"username":"[^"]*"' | tail -1 | cut -d'"' -f4)
FIRST_NAME=$(echo "$RESPONSE" | grep -o '"first_name":"[^"]*"' | tail -1 | cut -d'"' -f4)

echo ""
echo "================结果=================="
if [[ -z "$USER_ID" ]];then
    echo "❌ 获取失败！"
    echo "1、没有给机器人发消息"
    echo "2、Token填写错误"
else
    echo "✅ 获取成功"
    echo "用户ID(UserID): ${USER_ID}"
    echo "用户名(@): ${USER_NAME}"
    echo "昵称: ${FIRST_NAME}"
fi