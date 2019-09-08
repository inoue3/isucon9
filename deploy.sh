#!/bin/bash

PRIVATE_KEY=~/.ssh/isucon9
SERVER=47.74.47.25
APP_DIR=$GOPATH/src/github.com/inoue3/isucon9
REPO_DIR=$GOPATH/src/github.com/inoue3/isucon9

# build
cd $APP_DIR
make prod-build

ssh -i $PRIVATE_KEY isucon@$SERVER <<EOC
echo "# golang(app) stop"
sudo systemctl stop torb.go.service
echo "done"
EOC

scp -i $PRIVATE_KEY $APP_DIR/torb isucon@$SERVER:/home/isucon/torb/webapp/go/torb
scp -i $PRIVATE_KEY $APP_DIR/torb isucon@$PROXY_SERVER:/home/isucon/torb/webapp/go/torb
scp -i $PRIVATE_KEY $APP_DIR/torb isucon@$MYSQL_SERVER:/home/isucon/torb/webapp/go/torb
scp -i $PRIVATE_KEY $APP_DIR/db/schema.sql isucon@$SERVER:/home/isucon/torb/db/schema.sql
scp -i $PRIVATE_KEY $APP_DIR/db/schema.sql isucon@$PROXY_SERVER:/home/isucon/torb/db/schema.sql
scp -i $PRIVATE_KEY $APP_DIR/db/schema.sql isucon@$MYSQL_SERVER:/home/isucon/torb/db/schema.sql

ssh -i $PRIVATE_KEY isucon@$SERVER <<EOC
echo "# golang torb(app) start"
sudo systemctl start torb.go.service
echo "done"
EOC

ssh -i $PRIVATE_KEY isucon@$MYSQL_SERVER <<EOC
echo "# golang torb(mysql) start"
sudo systemctl start torb.go.service
echo "done"

echo "# mysql log rotate"
sudo mv /var/log/mysql/mysql-slow.log /var/log/mysql/mysql-slow.log.$(date +%Y%m%d%H%M%S)
sudo mysql -uroot -ppassword -e'FLUSH SLOW LOGS'
echo "done"
EOC

ssh -i $PRIVATE_KEY isucon@$PROXY_SERVER <<EOC
echo "# golang torb(proxy) start"
sudo systemctl start torb.go.service
echo "done"

echo "# nginx log rotate"
sudo mv /var/log/nginx/access.log /var/log/nginx/access.log.$(date +%Y%m%d%H%M%S)
sudo systemctl restart nginx.service
echo "done"
EOC
