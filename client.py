#!/usr/bin/env python3
import socket
import ssl
from pprint import pprint

# client
if __name__ == '__main__':

    hostname = '127.0.0.1'
    # PROTOCOL_TLS_CLIENT requires valid cert chain and hostname
    context = ssl.SSLContext(ssl.PROTOCOL_TLS_CLIENT)
    context.load_verify_locations('root_ca.pem')
    context.check_hostname = False

    # Enable client authentication
    context.load_cert_chain('client_chain.pem', 'client.key')

    with socket.create_connection((hostname, 8443)) as sock:
        with context.wrap_socket(sock, server_hostname=hostname) as ssock:
            print('Peer Certificate:')
            pprint(ssock.getpeercert())

            ssock.write(b'hello')
            print('Received:', ssock.read(1024))

