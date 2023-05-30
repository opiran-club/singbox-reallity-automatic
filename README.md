### Reallity Bash Script OneClick

#### اسکریپت گزینه های زیر را ارائه می دهد:

   ##### نصب موجود را حذف کرده و نصب جدیدی را انجام میدهد.
   
   ##### پیکربندی Sing-Box موجود را با تعیین یک پورت جدید و نام سرور تغییر و لینک اصلاح شده پس از تغییرات نمایش داده می شود.
   
   ##### تمام فایل های مرتبط را حذف میکند.


#### To install copy and paste below link

```
bash <(curl -fsSL https://raw.githubusercontent.com/opiran-club/singbox-reallity-automatic/main/install.sh --ipv4)
```

### For full installation go to the "full" folder

### برای نصب کامل به پوشه "Full" بروید

## Or Install from the source:

##### Requirements
 - Linux & Systemd
 - Git
 - C compiler environment

#### A) Install
```
git clone -b main https://github.com/SagerNet/sing-box && cd sing-box
```
##### skip if you have golang already installed
```
./release/local/install_go.sh
```
##### Install Core
```
./release/local/install.sh
```

#### B) Edit configuration file
```
nano /usr/local/etc/sing-box/config.json
```

#### C) Start Core
```
./release/local/enable.sh
```

#### D) Update the core
```
./release/local/update.sh
```

#### E) Other commands

##### Start	
```
sudo systemctl start sing-box
```
##### Stop
```
sudo systemctl stop sing-box
```
##### Kill
```
sudo systemctl kill sing-box
```
##### Restart
```
sudo systemctl restart sing-box
```
##### Logs
```
sudo journalctl -u sing-box --output cat -e
```
##### New Logs
```
sudo journalctl -u sing-box --output cat -f
```
##### Uninstall
```
./release/local/uninstall.sh
```

