#!/bin/bash

PRIVATE_KEY=~/.ssh/isucon9
SERVER_1=47.74.47.25
SERVER_2=47.74.17.204
SERVER_3=47.74.3.151
APP_DIR=$GOPATH/src/github.com/inoue3/isucon9/webapp/go
REPO_DIR=$GOPATH/src/github.com/inoue3/isucon9/webapp/go
SQL_DIR=$GOPATH/src/github.com/inoue3/isucon9/webapp/sql

# build
cd $APP_DIR
rm -f prod-isucari
make prod-isucari

ssh -i $PRIVATE_KEY isucon@$SERVER_1 <<EOC
echo "# golang app 1 stop"
sudo systemctl stop isucari.golang.service
echo "done"
EOC

ssh -i $PRIVATE_KEY isucon@$SERVER_2 <<EOC
echo "# golang app 2 stop"
sudo systemctl stop isucari.golang.service
echo "done"
EOC

# upload isucari app
scp -i $PRIVATE_KEY $APP_DIR/prod-isucari isucon@$SERVER_1:/home/isucon/isucari/webapp/go/isucari
scp -i $PRIVATE_KEY $APP_DIR/prod-isucari isucon@$SERVER_2:/home/isucon/isucari/webapp/go/isucari

# upload sql
scp -i $PRIVATE_KEY -r $SQL_DIR/* isucon@$SERVER_1:/home/isucon/isucari/webapp/sql/
scp -i $PRIVATE_KEY -r $SQL_DIR/* isucon@$SERVER_2:/home/isucon/isucari/webapp/sql/

ssh -i $PRIVATE_KEY isucon@$SERVER_1 <<EOC
echo "# golang app 1 start"
sudo systemctl start isucari.golang.service
echo "done"
EOC

ssh -i $PRIVATE_KEY isucon@$SERVER_2 <<EOC
echo "# golang app 2 start"
sudo systemctl start isucari.golang.service
echo "done"
EOC

#ssh -i $PRIVATE_KEY isucon@$SERVER <<EOC
#echo "# mysql log rotate"
#sudo mv /var/log/mysql/mysql-slow.log /var/log/mysql/mysql-slow.log.$(date +%Y%m%d%H%M%S)
#sudo mysql -uroot -ppassword -e'FLUSH SLOW LOGS'
#echo "done"
#EOC

ssh -i $PRIVATE_KEY isucon@$SERVER_1 <<EOC
echo "# nginx log rotate"
sudo mv /var/log/nginx/access.log /var/log/nginx/access.log.$(date +%Y%m%d%H%M%S)
sudo systemctl restart nginx.service
sudo chown isucon /var/log/nginx/access.log
echo "done"
EOC

ssh -i $PRIVATE_KEY isucon@$SERVER_2 <<EOC
echo "# nginx log rotate"
sudo mv /var/log/nginx/access.log /var/log/nginx/access.log.$(date +%Y%m%d%H%M%S)
sudo systemctl restart nginx.service
sudo chown isucon /var/log/nginx/access.log
echo "done"
EOC
