sudo apt-get update -y && sudo apt-get upgrade -y && sudo apt-get dist-upgrade -y
wget -qO - https://www.mongodb.org/static/pgp/server-4.2.asc | sudo apt-key add -
echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.2.list
sudo apt-get update -y && sudo apt-get install -y mongodb-org git nginx
sudo systemctl enable mongod && sudo systemctl start mongod
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
cat > /etc/nginx/sites-enabled/default << EOF
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
