
Source: "https://sing-box.sagernet.org/installation/from-source/"

#### A) Install gcc
```
apt update && apt install -y build-essential
```

#### B) install the latest Go-lang
```
curl -fsL https://raw.githubusercontent.com/jetsung/golang-install/main/install.sh | bash
source /root/.bashrc
```

#### C) install the dev-next branch of sing-box
```
go install -v -tags "with_clash_api with_quic with_grpc with_wireguard with_shadowsocksr with_ech with_utls with_acme with_v2ray_api with_gvisor with_lwip" github.com/sagernet/sing-box/cmd/sing-box@dev-next
```

#### D) Allow all users to run sing-box
```
cp ~/go/bin/sing-box /usr/local/bin/
```

#### E) create a sing-box directory to store assets and configurations
```
mkdir /etc/sing-box/ && cd $_
```

#### F) Creating sing-box systemd service
```
cat <<EOF > /etc/systemd/system/sing-box.service
[Unit]
Description=sing-box Service
Documentation=https://sing-box.sagernet.org/
After=network.target nss-lookup.target
Wants=network.target
[Service]
Type=simple
ExecStart=/usr/local/bin/sing-box run -c /etc/sing-box/config.json
Restart=always
RestartSec=3s
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000
[Install]
WantedBy=multi-user.target
EOF
```
#### G) customized the config.json

   ###### you can use my pre made config as you see above folders
   ###### or you can build by your own at the end of the page
   
#### after compleat above configuration so going to next level

#### H) Enable and start the Sing-Box service
```
systemctl daemon-reload && systemctl enable --now sing-box
```

#### I) Update SingBox at least once per week as it is actively developed
```
systemctl stop sing-box
go install -v -tags "with_acme with_ech with_quic with_utls with_v2ray_api with_clash_api with_gvisor with_lwip with_grpc with_quic with_wireguard with_ech with_utls with_gvisor with_shadowsocksr" github.com/sagernet/sing-box/cmd/sing-box@dev-next
cp ~/go/bin/sing-box /usr/local/bin/
systemctl start sing-box
```

#### J) Check your config.json for errors
```
sing-box check -c /etc/sing-box/config.json
```

#### K) Do not concern yourself with additional spaces, tabs, or formatting errors when editing the config file. Sing-Box can automatically correct the file format. Execute the following command
```
sing-box format -wc /etc/sing-box/config.json
```

#### L) Finnesh and Enjoy Singbox Core and Free Internet
