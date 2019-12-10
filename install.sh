#!/bin/bash
if [ -n "$(command -v apt-get)" ]
then
	apt-get update -y
	wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | sudo apt-key add -
	echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.2.list
	apt-get update -y && apt-get install -y mongodb-org git nginx
	NGINX_VHOST=/etc/nginx/sites-enabled/default
elif [ -n "$(command -v yum)" ]
then
	yum update -y
	cat > /etc/yum.repos.d/mongodb-org-4.2.repo << EOF
		[mongodb-org-4.2]
		name=MongoDB Repository
		baseurl=https://repo.mongodb.org/yum/redhat/\$releasever/mongodb-org/4.2/x86_64/
		gpgcheck=1
		enabled=1
		gpgkey=https://www.mongodb.org/static/pgp/server-4.2.asc
EOF
	cat > /etc/yum.repos.d/nginx.repo << EOF
		[nginx]
		name=nginx repo
		baseurl=http://nginx.org/packages/mainline/centos/7/$basearch/
		gpgcheck=0
		enabled=1
EOF
	yum install -y mongodb-org git nginx
	NGINX_VHOST=/etc/nginx/conf.d/reddit.conf
fi
systemctl enable mongod && systemctl start mongod
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.1/install.sh | bash
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
nvm install 12
npm i -g pm2
cd /opt/
#git clone https://github.com/d11z/asperitas
git clone https://github.com/arifjaunpur/asperitas
cd asperitas/server && npm i
cd ../client && npm i
export NODE_ENV=production
npm run build
rm -rf /var/www/html && mv build /var/www/html
cd ../server && pm2 start index.js --name api
pm2 startup
pm2 save
sudo service nginx stop
rm -rf /etc/nginx/sites-enabled/default
cat > $NGINX_VHOST << EOF
server {
        listen 80 default_server;
        listen [::]:80 default_server;

        root /var/www/html;

        index index.html index.htm;

        server_name _;
		
        location /api {
                proxy_pass http://127.0.0.1:8080;
                proxy_http_version 1.1;
                proxy_set_header Upgrade \$http_upgrade;
                proxy_set_header Connection 'upgrade';
                proxy_set_header Host \$host;
                proxy_cache_bypass \$http_upgrade;
        }
        location / {
                #try_files $uri \$uri/ =404;
                try_files \$uri /index.html;
        }
}
EOF

sudo service nginx start
sudo reboot
