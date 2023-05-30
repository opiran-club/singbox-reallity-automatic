
Source: "https://sing-box.sagernet.org/installation/from-source/"

Many Thanks to : https://vpnrouter.homes/

Step-By-Step Follow Instructions
گام به گام دستورالعمل ها را دنبال کنید

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
   همانطور که در پوشه ی بالا می بینید می توانید از تنظیمات از پیش ساخته شده من استفاده کنید

   ###### or you can build by your own at the end of the page
   یا می توانید خودتان با کمک راهنمای انتهای صفحه, آن را بسازید
   
#### after compleat above configuration so going to next level
   پس از تکمیل پیکربندی بالا، به مرحله بعد بروید

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
   هنگام ویرایش فایل پیکربندی، نگران فضاهای اضافی، برگه ها یا خطاهای قالب بندی نباشید. Sing-Box می تواند به طور خودکار فرمت فایل را تصحیح کند. دستور زیر را اجرا کنید
```
sing-box format -wc /etc/sing-box/config.json
```

#### L) Finnesh and Enjoy Singbox Core and Free Internet
   از اینترنت بدون سانسور لذت ببرید

 
### building your personal config.json
   ساخت پیکربندی شخصی شما

#### Structure
```
{
  "log": {},
  "dns": {},
  "ntp": {},
  "inbounds": [],
  "outbounds": [],
  "route": {},
  "experimental": {}
}
```
##### Log Structure
 - Log level: trace, debug, info, warn, error, fatal, panic.
```
{
  "log": {
    "disabled": false,
    "level": "info",
    "output": "box.log",
    "timestamp": true
  }
}
```
##### DNS Structure
 - strategy: prefer_ipv4, prefer_ipv6, ipv4_only, ipv6_only.
```
{
  "dns": {
    "servers": [],
    "rules": [],
    "final": "",
    "strategy": "",
    "disable_cache": false,
    "disable_expire": false,
    "independent_cache": false,
    "reverse_mapping": false,
    "fakeip": {}
  }
}
```
##### NTP Built-in NTP client service.

 - If enabled, it will provide time for protocols like TLS/Shadowsocks/VMess, which is useful for environments where time synchronization is not possible.
```
{
  "ntp": {
    "enabled": false,
    "server": "time.apple.com",
    "server_port": 123,
    "interval": "30m",

    ... // Dial Fields
  }
}
```
##### Inbound Structure
 - Type : direct, mixed, socks, http, shadowsocks, vmess, trojan, naive, hysteria, shadowtls, vless, tun, redirect, tproxy.

```
{
  "inbounds": [
    {
      "type": "",
      "tag": ""
    }
  ]
}
```
##### Outbound structure
 - Type: direct, block, socks, http, shadowsocks, trojan, wireguard, hysteria, vless, shadowtls, tor, ssh, dns, selector. urltest
 	
``
{
  "outbounds": [
    {
      "type": "",
      "tag": ""
    }
  ]
}
```
##### Exprimental:
 - visit the page for more info: https://sing-box.sagernet.org/configuration/experimental/#secret

##### Routing
 - visit the page for more info: https://sing-box.sagernet.org/configuration/route/



#### sample config:
 - visit this page: https://vpnrouter.homes/build-singbox-config
 
 
