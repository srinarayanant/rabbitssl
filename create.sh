cd /etc/rabbitmq
rm -rf server/ testca/ client/

cd /etc/rabbitmq
mkdir testca
cd testca
mkdir certs private
chmod 700 private
echo 01 > serial
touch index.txt

cd /etc/rabbitmq
\cp openssl.cnf testca/openssl.cnf -fr


cd /etc/rabbitmq/testca
openssl req -x509 -config openssl.cnf -newkey rsa:2048 -days 365 \
   -out cacert.pem -outform PEM -subj /CN=DR2CCA/ -nodes
  
openssl x509 -in cacert.pem -out cacert.cer -outform DER

cd /etc/rabbitmq
mkdir server
cd server
openssl genrsa -out key.pem 2048
openssl req -new -key key.pem -out req.pem -outform PEM \
    -subj /CN=$(hostname)/O=server/ -nodes
 
 
 
cd /etc/rabbitmq/testca
openssl ca -config openssl.cnf -in /etc/rabbitmq/server/req.pem -out \
    /etc/rabbitmq/server/cert.pem -notext -batch -extensions server_ca_extensions
 
cd /etc/rabbitmq/server
openssl pkcs12 -export -out keycert.p12 -in cert.pem -inkey key.pem -passout pass:MySecretPassword

cd /etc/rabbitmq
mkdir client
cd client
openssl genrsa -out key.pem 2048
openssl req -new -key key.pem -out req.pem -outform PEM \
    -subj /CN=$(hostname)/O=client/ -nodes
 
cd /etc/rabbitmq/testca
openssl ca -config openssl.cnf -in /etc/rabbitmq/client/req.pem -out \
    /etc/rabbitmq/client/cert.pem -notext -batch -extensions server_ca_extensions
 
cd /etc/rabbitmq/client
openssl pkcs12 -export -out keycert.p12 -in cert.pem -inkey key.pem -passout pass:MySecretPassword

chown -R rabbitmq: /etc/rabbitmq/testca
chown -R rabbitmq: /etc/rabbitmq/server
chown -R rabbitmq: /etc/rabbitmq/client

