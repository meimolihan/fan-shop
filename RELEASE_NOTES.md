自动构建发布 v2.1.12

```bash
docker pull mobufan/fan-shop:latest
```
```bash
docker pull mobufan/fan-shop:v2.1.12
```

```bash
docker pull ghcr.io/meimolihan/fan-shop:latest
```
```bash
docker pull ghcr.io/meimolihan/fan-shop:v2.1.12
```

## 源码安装
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/meimolihan/fan-shop/main/scripts/install.sh)
```

## 源码卸载（保留数据）
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/meimolihan/fan-shop/main/scripts/uninstall.sh)
```

## 源码卸载（连数据一并删除）
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/meimolihan/fan-shop/main/scripts/uninstall.sh) --purge
```
