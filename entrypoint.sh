if [ ! -f config/ssl_key.pem ];
then
  openssl req \
    -new \
    -newkey rsa:4096 \
    -days 365 \
    -nodes \
    -x509 \
    -subj "/C=NA/ST=NA/L=NA/O=NA/CN=$(hostname)" \
    -keyout config/ssl_key.pem \
    -out config/ssl_cert.pem
fi

exec mix phoenix.server
