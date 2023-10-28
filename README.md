Example to build a mutually authenticated SSL connection

## Usage
First run `gen_certs.sh`. This will generate a root, intermediate, server and client certificate. The server and client certificates are both signed by the intermediate, which is signed by the root certificate.

Then run `server.py` which will open a echo server on port 8443.

Finally run `client.py` which will connect to the server. 

The connection is mutually authenticated through the client and server certificates.