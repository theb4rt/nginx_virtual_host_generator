#!/bin/bash

DOMAIN=$1
SITES_AVAILABLE="/etc/nginx/sites-available/"

arrDOM=(${DOMAIN//./ })                                                              
arrDOM_LEN="${#arrDOM[@]}"
host=\$'host'
uri=\$'uri'
request_method=\$'request_method'
request_uri=\$'request_uri'
document_root=\$'document_root'
fastcgi_script_name=\$'fastcgi_script_name'
document_root=\$'document_root'
query_string=\$'query_string'


FULL_PATH_VH=$SITES_AVAILABLE$DOMAIN.conf
echo "full_path: "$FULL_PATH_VH

if [ ! -f "$FULL_PATH_VH" ]
then
  if [ $arrDOM_LEN == 2 ]
  then
    echo "Type DOMAIN"
    echo "path: "$FULL_PATH_VH
     sudo bash -c "cat << EOF >$FULL_PATH_VH
server {
        client_max_body_size 500M;

        if ( \\$host = www.$DOMAIN) {
            return 301 https://\\$host\\$request_uri;
        } 

        if ( \\$host = $DOMAIN) {
            return 301 https://\\$host\\$request_uri;
        } 

       if ( \\$request_method !~ ^(GET|HEAD|POST)$ )
        {
        return 405;
        }

        listen       80;
        server_name  $DOMAIN  www.$DOMAIN;
        return       301 https://$DOMAIN\\$request_uri;
    }

    server {
        client_max_body_size 500M;

        listen 443 ssl http2;
        server_name $DOMAIN;
        ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt; 
        ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key; 
        #include /etc/letsencrypt/options-ssl-nginx.conf; 
        #ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; 

        root /var/www/$DOMAIN/public_html/;

        index index.php index.html index.htm;

            location / {
                   try_files \\$uri \\$uri/ /index.php?\\$query_string;
            }

          if (\\$request_method !~ ^(GET|HEAD|POST)$ )
            {
            return 405;
            }

        location ~* \.php$ {


        # With php-fpm unix sockets
        try_files \\$uri =404;
        fastcgi_pass unix:/run/php/php7.4-fpm.sock;
        fastcgi_index index.php;
        include         fastcgi_params;
        fastcgi_param   SCRIPT_FILENAME    \\$document_root\\$fastcgi_script_name;
        fastcgi_param   SCRIPT_NAME        \\$fastcgi_script_name;
    }
    }

    server {

        client_max_body_size 500M;
            

        listen 443 ssl http2;
        server_name  www.$DOMAIN;
        ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt; 
        ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key; 
        #include /etc/letsencrypt/options-ssl-nginx.conf; 
        #ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; 


        root /var/www/$DOMAIN/public_html/;

        index index.php index.html index.htm;

            location / {
      
                   try_files \\$uri \\$uri/ /index.php?\\$query_string;
            }

        if (\\$request_method !~ ^(GET|HEAD|POST)$ )
            {
            return 405;
            }

        location ~* \.php$ 
    {
        # With php-fpm unix sockets
        try_files \\$uri =404;
        fastcgi_pass unix:/run/php/php7.4-fpm.sock;
        fastcgi_index index.php;
        include         fastcgi_params;
        fastcgi_param   SCRIPT_FILENAME    \\$document_root\\$fastcgi_script_name;
        fastcgi_param   SCRIPT_NAME        \\$fastcgi_script_name;

    }
    }

EOF
"

elif [ $arrDOM_LEN == 3 ]
then
  echo "Type SUBDOMAIN"
  echo "path: "$FULL_PATH_VH
 sudo bash -c "cat << EOF > $FULL_PATH_VH  
        server {
        client_max_body_size 500M;

        if (\\$host = $DOMAIN) {
            return 301 https://\\$host\\$request_uri;
        }

        if (\\$request_method !~ ^(GET|HEAD|POST)$ )
          {
          return 405;
          }

        listen       80;
        server_name  $DOMAIN ;
        return       301 https://$DOMAIN\\$request_uri;
    }

    server {
        client_max_body_size 500M;

        listen 443 ssl http2;
        server_name $DOMAIN;
        ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;
        ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;
        #include /etc/letsencrypt/options-ssl-nginx.conf;
        #ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

        root /var/www/$DOMAIN/public_html/;

        index index.php index.html index.htm;

            location / {
                   try_files \\$uri \\$uri/ /index.php?\\$query_string;
            }

          if (\\$request_method !~ ^(GET|HEAD|POST)$ )
            {
            return 405;
            }

        location ~* \.php$ {


        # With php-fpm unix sockets
        try_files \\$uri =404;
        fastcgi_pass unix:/run/php/php7.4-fpm.sock;
        fastcgi_index index.php;
        include         fastcgi_params;
        fastcgi_param   SCRIPT_FILENAME    \\$document_root\\$fastcgi_script_name;
        fastcgi_param   SCRIPT_NAME        \\$fastcgi_script_name;
    }
    }
EOF
"

  else
    echo "BAD DOMAIN: "$DOMAIN
  fi
else
  echo "FILE ALREADY EXIST "$FULL_PATH_VH
fi
        
