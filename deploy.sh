#!/bin/bash

PRIVATE_KEY=~/.ssh/isucon9
SERVER=47.74.47.25
APP_DIR=$GOPATH/src/github.com/inoue3/isucon9/webapp/go
REPO_DIR=$GOPATH/src/github.com/inoue3/isucon9/webapp/go

# build
cd $APP_DIR
make prod-isucari

ssh -i $PRIVATE_KEY isucon@$SERVER <<EOC
echo "# golang app stop"
sudo systemctl stop isucari.golang.service
echo "done"
EOC

scp -i $PRIVATE_KEY $APP_DIR/prod-isucari isucon@$SERVER:/home/isucon/isucari/webapp/go/isucari

ssh -i $PRIVATE_KEY isucon@$SERVER <<EOC
echo "# golang app start"
sudo systemctl start isucari.golang.service
echo "done"
EOC

#ssh -i $PRIVATE_KEY isucon@$SERVER <<EOC
#echo "# mysql log rotate"
#sudo mv /var/log/mysql/mysql-slow.log /var/log/mysql/mysql-slow.log.$(date +%Y%m%d%H%M%S)
#sudo mysql -uroot -ppassword -e'FLUSH SLOW LOGS'
#echo "done"
#EOC

ssh -i $PRIVATE_KEY isucon@$SERVER <<EOC
echo "# nginx log rotate"
sudo mv /var/log/nginx/access.log /var/log/nginx/access.log.$(date +%Y%m%d%H%M%S)
sudo systemctl restart nginx.service
sudo chown isucon /var/log/nginx/access.log
echo "done"
EOC
