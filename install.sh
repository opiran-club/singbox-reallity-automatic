#!/bin/bash

# Function to print characters with delay
print_with_delay() {
    text=$1
    delay=$2
    for ((i = 0; i < ${#text}; i++)); do
        echo -n "${text:$i:1}"
        sleep $delay
    done
}

# Introduction animation
echo ""
echo ""
print_with_delay "b" 0.1
print_with_delay "y" 0.1
print_with_delay " " 0.1
print_with_delay "O" 0.1
print_with_delay "P" 0.1
print_with_delay "I" 0.1
print_with_delay "R" 0.1
print_with_delay "N" 0.1
print_with_delay "C" 0.1
print_with_delay "L" 0.1
print_with_delay "U" 0.1
print_with_delay "B" 0.1
print_with_delay ""
echo ""
echo ""


# Check if jq is installed, and install it if not
if ! command -v jq &> /dev/null; then
    echo "jq is not installed. Installing..."
    if [ -n "$(command -v apt)" ]; then
        apt update
        apt install -y jq
    elif [ -n "$(command -v yum)" ]; then
        yum install -y epel-release
        yum install -y jq
    elif [ -n "$(command -v dnf)" ]; then
        dnf install -y jq
    else
        echo "Cannot install jq. Please install jq manually and rerun the script."
        exit 1
    fi
fi

# Check if reality.json, sing-box, and sing-box.service already exist
if [ -f "/root/reality.json" ] && [ -f "/root/sing-box" ] && [ -f "/etc/systemd/system/sing-box.service" ]; then

    echo ".روی سرور شما هسته سینک باکس نصب است"
    echo ""
    echo ":لطفا یک گزینه را انتخاب کنید"
    echo ""
    echo "1. نصب یا نصب مجدد"
    echo "2. تغییر پورت و اس ان آی"
    echo "3. حذف هسته سینک باکس"
    echo ""
    read -p ":انتخاب خود را وارد کنید (3-1)" choice

    case $choice in
        1)
            echo " ...نصب مجدد"
            systemctl stop sing-box
            systemctl disable sing-box
            rm /etc/systemd/system/sing-box.service
            rm /root/reality.json
            rm /root/sing-box

            ;;
        2)
            echo "... در حال تغییرات"
	    # Get current listen port
	    current_listen_port=$(jq -r '.inbounds[0].listen_port' /root/reality.json)

	    read -p "Enter desired listen port (Current port is $current_listen_port): " listen_port
	    listen_port=${listen_port:-$current_listen_port}

	    current_server_name=$(jq -r '.inbounds[0].tls.server_name' /root/reality.json)

	    read -p "Enter server name/SNI (Current value is $current_server_name): " server_name
	    server_name=${server_name:-$current_server_name}

	    jq --arg listen_port "$listen_port" --arg server_name "$server_name" '.inbounds[0].listen_port = ($listen_port | tonumber) | .inbounds[0].tls.server_name = $server_name | .inbounds[0].tls.reality.handshake.server = $server_name' /root/reality.json > /root/reality_modified.json
	    mv /root/reality_modified.json /root/reality.json

	    systemctl restart sing-box
	    echo "DONE!"
	    exit 0
            ;;
        3)
            echo "در حال حذف اسکریپت"
            systemctl stop sing-box
            systemctl disable sing-box

            rm /etc/systemd/system/sing-box.service
            rm /root/reality.json
            rm /root/sing-box
	    echo "DONE!"
            exit 0
            ;;
        *)
            echo "انتخاب نامعتبراست و خروج"
            exit 1
            ;;
    esac
fi

latest_version=$(curl -s "https://api.github.com/repos/SagerNet/sing-box/releases" | jq -r '.[0].name')

arch=$(uname -m)

case ${arch} in
    x86_64)
        arch="amd64"
        ;;
    aarch64)
        arch="arm64"
        ;;
    armv7l)
        arch="armv7"
        ;;
esac

package_name="sing-box-${latest_version}-linux-${arch}"

curl -sLo "/root/${package_name}.tar.gz" "https://github.com/SagerNet/sing-box/releases/download/v${latest_version}/${package_name}.tar.gz"

tar -xzf "/root/${package_name}.tar.gz" -C /root
mv "/root/${package_name}/sing-box" /root/

rm -r "/root/${package_name}.tar.gz" "/root/${package_name}"

chown root:root /root/sing-box
chmod +x /root/sing-box

echo "... ایجاد کلید"
key_pair=$(/root/sing-box generate reality-keypair)
echo ".ایجاد کلید کامل شده است"
echo

private_key=$(echo "$key_pair" | awk '/PrivateKey/ {print $2}' | tr -d '"')
public_key=$(echo "$key_pair" | awk '/PublicKey/ {print $2}' | tr -d '"')

uuid=$(/root/sing-box generate uuid)
short_id=$(/root/sing-box generate rand --hex 8)

read -p "Enter desired listen port (دریافت پورت)(default: 443): " listen_port
listen_port=${listen_port:-443}

read -p "Enter server name/SNI (دریافت اس ان آی)(default: zula.ir): " server_name
server_name=${server_name:-zula.ir}

server_ip=$(curl -s https://api.ipify.org)

jq -n --arg listen_port "$listen_port" --arg server_name "$server_name" --arg private_key "$private_key" --arg short_id "$short_id" --arg uuid "$uuid" --arg server_ip "$server_ip" '{
  "log": {
    "level": "info",
    "timestamp": true
  },
  "inbounds": [
    {
      "type": "vless",
      "tag": "vless-in",
      "listen": "::",
      "listen_port": ($listen_port | tonumber),
      "sniff": true,
      "sniff_override_destination": true,
      "domain_strategy": "ipv4_only",
      "users": [
        {
          "uuid": $uuid,
          "flow": "xtls-rprx-vision"
        }
      ],
      "tls": {
        "enabled": true,
        "server_name": $server_name,
          "reality": {
          "enabled": true,
          "handshake": {
            "server": $server_name,
            "server_port": 443
          },
          "private_key": $private_key,
          "short_id": [$short_id]
        }
      }
    }
  ],
  "outbounds": [
    {
      "type": "direct",
      "tag": "direct"
    },
    {
      "type": "block",
      "tag": "block"
    }
  ]
}' > /root/reality.json

# Create sing-box.service
cat > /etc/systemd/system/sing-box.service <<EOF
[Unit]
After=network.target nss-lookup.target

[Service]
User=root
WorkingDirectory=/root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW
ExecStart=/root/sing-box run -c /root/reality.json
ExecReload=/bin/kill -HUP \$MAINPID
Restart=on-failure
RestartSec=10
LimitNOFILE=infinity

[Install]
WantedBy=multi-user.target
EOF

if /root/sing-box check -c /root/reality.json; then
    echo "sing-box پیکربندی با موفقیت بررسی شد. شروع سرویس"
    systemctl daemon-reload
    systemctl enable sing-box
    systemctl start sing-box
    systemctl restart sing-box

# Generate the link

    server_link="vless://$uuid@$server_ip:$listen_port?encryption=none&flow=xtls-rprx-vision&security=reality&sni=$server_name&fp=chrome&pbk=$public_key&sid=$short_id&type=tcp&headerType=none#Reallity-TCP"

    server_link="vless://$uuid@$server_ip:$listen_port?encryption=none&flow=&serviceName=&mode=multi&security=reality&sni=$server_name&fp=chrome&pbk=$public_key&sid=$short_id&type=gRPC&headerType=none#Reallity-gRPC"

    # Print the server details
    echo
    echo "Server IP: $server_ip"
    echo "Listen Port: $listen_port"
    echo "Server Name: $server_name"
    echo "Public Key: $public_key"
    echo "Short ID: $short_id"
    echo "UUID: $uuid"
    echo ""
    echo ""
    echo ""
    echo " v2rayN و v2rayNG این لینک مخصوص"
    echo ""
    echo "$server_link"
else
    echo "خطا در پیکربندی و خروج"
fi

