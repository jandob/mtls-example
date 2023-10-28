#!/usr/bin/env bash
set -x # print commands
set -e # exit on error

# Generate a CSR and private key for root_ca
openssl req -new -newkey rsa:4096 -nodes -out root_ca.csr -keyout root_ca.key -subj '/C=DE/ST=BW/L=Freiburg/CN=Test Root CA'

# Self-sign root_ca
openssl x509 -trustout -signkey root_ca.key -days 365 -req -in root_ca.csr -out root_ca.pem
#openssl x509 -text -noout -in root_ca.pem

# Install root certificate 
sudo cp root_ca.pem /usr/local/share/ca-certificates/test_root_ca.crt
sudo update-ca-certificates

# Verify root certificate
openssl verify root_ca.pem 

# Generate a CSR and private key for intermediate_ca
openssl req -new -newkey rsa:2048 -nodes -out intermediate_ca.csr -keyout intermediate_ca.key -subj '/C=DE/ST=BW/L=Freiburg/CN=Test Intermediate CA'

# Have the root_ca sign the intermediate_ca's CSR
openssl x509 -req -days 365 -in intermediate_ca.csr -CA root_ca.pem -CAkey root_ca.key -set_serial 01 -out intermediate_ca.pem -extensions v3_ca -extfile <(printf "[v3_ca]\nbasicConstraints = CA:TRUE\n")

# Verify intermediate certificate
openssl verify intermediate_ca.pem 

# Generate a CSR and private key for the client
openssl req -new -newkey rsa:2048 -nodes -out client.csr -keyout client.key -subj '/C=DE/ST=BW/L=Freiburg/CN=client'

# Have the intermediate_ca sign the client's CSR
openssl x509 -req -CAcreateserial -days 365 -in client.csr -CA intermediate_ca.pem -CAkey intermediate_ca.key -out client.pem

# Generate a CSR and private key for the server
openssl req -new -newkey rsa:2048 -nodes -out server.csr -keyout server.key -subj '/C=DE/ST=BW/L=Freiburg/CN=server'

# Have the intermediate_ca sign the server's CSR
openssl x509 -req -CAcreateserial -days 365 -in server.csr -CA intermediate_ca.pem -CAkey intermediate_ca.key -out server.pem

# Create cert chain (bundle)
cat client.pem intermediate_ca.pem > client_chain.pem
cat server.pem intermediate_ca.pem > server_chain.pem

# Verify the device's certificate
# NOTE: openssl verify does not understand bundles, it stops after the first certificate. Thats why (opposed to ssl clients) we need to use -untrusted here. 
# NOTE2: -CAfile is not necessarily required here, because the root ca is installed in the system.
openssl verify -verbose -CAfile root_ca.pem -untrusted intermediate_ca.pem client.pem
openssl verify -verbose -untrusted intermediate_ca.pem server.pem

# Cleanup
rm *.csr
sudo rm /usr/local/share/ca-certificates/test_root_ca.crt
sudo update-ca-certificates -f

# now verification of the server cert fails
openssl verify -verbose -CAfile root_ca.pem -untrusted intermediate_ca.pem client.pem
openssl verify -verbose -untrusted intermediate_ca.pem server.pem || true # expected to fail

