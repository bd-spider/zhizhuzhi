#!/bin/bash

# 更新系统并安装必要的软件包
echo "更新系统..."
sudo apt update -y
sudo apt upgrade -y

# 安装 Fail2Ban（防止暴力破解）
echo "安装 Fail2Ban..."
sudo apt install -y fail2ban

# 启用 SYN Cookies 来防止 SYN Flood 攻击
echo "启用 SYN Cookies..."
sudo sysctl -w net.ipv4.tcp_syncookies=1

# 永久启用 SYN Cookies（修改 sysctl 配置）
echo "配置永久启用 SYN Cookies..."
echo "net.ipv4.tcp_syncookies = 1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# 调整 TCP 半连接队列的大小
echo "调整 TCP 半连接队列..."
sudo sysctl -w net.ipv4.tcp_max_syn_backlog=2048

# 永久设置 TCP 半连接队列大小（修改 sysctl 配置）
echo "net.ipv4.tcp_max_syn_backlog = 2048" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# 禁用 TCP 时间戳来减少 SYN Flood 攻击的影响
echo "禁用 TCP 时间戳..."
sudo sysctl -w net.ipv4.tcp_timestamps=0

# 永久禁用 TCP 时间戳（修改 sysctl 配置）
echo "net.ipv4.tcp_timestamps = 0" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# 配置防火墙，限制连接速率，防止大量的 SYN 请求
echo "配置防火墙，防止 SYN Flood 攻击..."
# 只允许每秒最多一个 SYN 包请求，并设置突发请求限制为3次
sudo iptables -A INPUT -p tcp --syn -m limit --limit 1/s --limit-burst 3 -j ACCEPT
sudo iptables -A INPUT -p tcp --syn -j DROP

# 保存防火墙规则
echo "保存防火墙规则..."
sudo iptables-save > /etc/iptables/rules.v4

# 启动 Fail2Ban 并设置为开机自启
echo "启动 Fail2Ban 并启用自启动..."
sudo systemctl start fail2ban
sudo systemctl enable fail2ban

# 完成防护配置
echo "SYN Flood 防护部署完成！服务器已启用防 SYN Flood 安全配置。"
