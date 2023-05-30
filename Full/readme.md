
Source: "https://sing-box.sagernet.org/installation/from-source/"

Many Thanks to : https://vpnrouter.homes/

Step-By-Step Follow Instructions

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


### building your own config.json

```
{
    "inbounds": [{
        "tag": "mixed-in"
    }, {
        "tag": "tun-in"
    }],
    "outbounds": [{
        "tag": "shadowsocks-out"
    }, {
        "tag": "vmess-ws-out"
    }],
    "route": {
        "final": "shadowsocks-out"
    }
}
Code language: JSON / JSON with Comments (json)
Replacing tags with actual json blocks:

{
	"inbounds": [{
		"type": "mixed",
		"tag": "mixed-in",
		"listen": "127.0.0.1",
		"listen_port": 1080,
		"tcp_fast_open": true,
		"sniff": true,
		"sniff_override_destination": true,
		"set_system_proxy": false
	}, {
		"type": "tun",
		"tag": "tun-in",
		"interface_name": "tun0",
		"inet4_address": "172.19.0.1/30",
		"inet6_address": "fdfe:dcba:9876::1/128",
		"stack": "gvisor",
		"mtu": 9000,
		"auto_route": true,
		"strict_route": true,
		"endpoint_independent_nat": false,
		"sniff": true,
		"sniff_override_destination": true
	}],
	"outbounds": [{
		"type": "shadowsocks",
		"tag": "shadowsocks-out",
		"server": "SERVER-IP-ADDRESS",
		"server_port": 5353,
		"method": "2022-blake3-aes-128-gcm",
		"password": "8JCsPssfgS8tiRwiMlhARg=="
	}, {
		"type": "vmess",
		"tag": "vmess-ws-out",
		"server": "SERVER-IP-ADDRESS",
		"server_port": 80,
		"uuid": "3c1890e2-c768-4247-8a3b-032f6ed13a64",
		"security": "auto",
		"alter_id": 0,
		"global_padding": false,
		"authenticated_length": true,
		"multiplex": {
			"enabled": true,
			"protocol": "smux",
			"max_connections": 5,
			"min_streams": 4,
			"max_streams": 0
		},
		"transport": {
			"type": "ws",
			"path": "/stream",
			"max_early_data": 0,
			"early_data_header_name": "Sec-WebSocket-Protocol"
		},
		"connect_timeout": "5s"
	}],
	"route": {
		"final": "shadowsocks-out"
	}
}
Code language: JSON / JSON with Comments (json)
Now that you understand how to have multiple inbounds and outbounds, here’s an additional example for you to use as a starting point when building your config.json:

{
	"log": {
		"disabled": false,
		"level": "error",
		"output": "box.log",
		"timestamp": true
	},
	"dns": {
		"servers": [{
				"tag": "local",
				"address": "217.218.127.127",
				"detour": "direct"
			},
			{
				"tag": "google",
				"address": "tls://8.8.8.8"
			}, {
				"tag": "block",
				"address": "rcode://success"
			}
		],
		"rules": [{
			"geosite": "category-ads-all",
			"server": "block"
		}, {
			"domain_suffix": ".ir",
			"server": "local"
		}],
		"final": "google",
		"strategy": "prefer_ipv4",
		"disable_cache": false,
		"disable_expire": false
	},
	"inbounds": [{
		"tag": "inbound1"
	}, {
		"tag": "inbound2"
	}, {
		"tag": "inbound3"
	}, {
		"tag": "inbound4"
	}],
	"outbounds": [{
		"tag": "outbound1"
	}, {
		"tag": "outbound2"
	}, {
		"tag": "outbound3"
	}, {
		"tag": "outbound4"
	}, {
		"tag": "outbound5"
	}],
	"route": {
		"geoip": {
			"download_url": "https://github.com/SagerNet/sing-geoip/releases/latest/download/geoip.db",
			"download_detour": "direct"
		},
		"geosite": {
			"download_url": "https://github.com/SagerNet/sing-geosite/releases/latest/download/geosite.db",
			"download_detour": "direct"
		},
		"rules": [{
				"protocol": "dns",
				"outbound": "dns-out"
			}, {
				"geosite": [
					"category-ads-all"
				],
				"domain_keyword": [
					"yektanet",
					"adengine.telewebion.com"
				],
				"outbound": "block"
			},
			{
				"geoip": "private",
				"domain_suffix": [
					".ir",
					"aparat.com",
					"digikala.com",
					"telewebion.com",
					"varzesh3.com"
				],
				"port": [
					22,
					3389
				],
				"outbound": "direct"
			}
		],
		"final": "outbound2",
		"auto_detect_interface": true
	},
	"experimental": {}
}
```
