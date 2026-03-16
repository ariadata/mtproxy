# MTProxy with docker-compose

[![Build Status](https://raw.githubusercontent.com/ariadata/ariadata-files/main/public-assets/images/ariadata_logo.png)](https://ariadata.co)

![](https://img.shields.io/github/stars/ariadata/mtproxy.svg)
![](https://img.shields.io/github/watchers/ariadata/mtproxy.svg)
![](https://img.shields.io/github/forks/ariadata/mtproxy.svg)
[![License](https://img.shields.io/github/license/ariadata/mtproxy.svg)](https://github.com/ariadata/mtproxy/blob/main/LICENSE)

### This needs [docker , docker-compose](https://github.com/ariadata/dockerhost-sh) Installed

---

## 1- Clone the repository

```bash
git clone -b main https://github.com/ariadata/mtproxy.git && cd mtproxy
```

## 2- Copy`env` file from `.env.example`

```bash
cp .env.example .env
```

## 3- Generate SECRET by using one of these :

```
echo $(head -c 16 /dev/urandom | xxd -ps)

echo $(openssl rand -hex 16)
```



## 4- Modify `.env` file if you need

| Variable                  | Default            | Description                                                     |
| ------------------------- | ------------------ | --------------------------------------------------------------- |
| `INTERNAL_PORT`           | 443                | Internal proxy port                                             |
| `EXTERNAL_PORT`           | 443                | Port exposed to the host                                        |
| `EXTERNAL_HOST`           | (auto)             | Your server IP or domain. Auto-detected if empty                |
| `ENABLE_TLS`              | true               | Use fake TLS (recommended)                                      |
| `TLS_DOMAIN`              | www.cloudflare.com | Domain for fake TLS                                             |
| `WORKERS`                 | 2                  | Number of worker processes                                      |
| `MAX_SPECIAL_CONNECTIONS` | 60000              | Max connections                                                 |
| `SECRET`                  | (auto)             | 32-char hex secret(s), comma-separated. Auto-generated if empty |
| `TAG`                     | (empty)            | 32-char hex tag for Telegram promotion                          |

## 5- Run the stack

```bash
docker compose up -d
```

## 6- Get your proxy links

After the container starts, run:

```bash
docker compose exec mtproxy get_links
```

Or view stats:

```bash
docker compose exec mtproxy getstats
```

## 7- Share the link with users

Open the link in Telegram (e.g. `https://t.me/proxy?server=YOUR_IP&port=443&secret=...`) or share the output from `get_links`.

---

## License

This project is licensed under the MIT License — see the [LICENSE](https://github.com/ariadata/mtproxy/blob/main/LICENSE) file for details.


