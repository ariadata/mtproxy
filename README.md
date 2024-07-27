# mtproxy with docker dompose
[![Build Status](https://raw.githubusercontent.com/ariadata/ariadata-files/main/public-assets/images/ariadata_logo.png)](https://ariadata.co)

## Clone this repository
```bash
git clone -b main --depth=1 https://github.com/ariadata/mtproxy dc-mtproxy

cd dc-mtproxy

# change parameters in .env file for SECRET Use:
# head -c 16 /dev/urandom | xxd -ps
# or via : https://www.browserling.com/tools/random-hex

docker-compose up -d

# wait about 10 seconds
docker-compose logs

```
