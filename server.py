#!/usr/bin/env python3
import socket
import ssl
from pprint import pprint


#server
if __name__ == '__main__':

    context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
    context.load_cert_chain('server_chain.pem', 'server.key')

    # Enable client authentication
    context.load_verify_locations('root_ca.pem')
    context.verify_mode = ssl.CERT_REQUIRED

    with socket.socket(socket.AF_INET, socket.SOCK_STREAM, 0) as sock:
        sock.bind(('127.0.0.1', 8443))
        sock.listen(10)
        with context.wrap_socket(sock, server_side=True) as ssock:
            conn, addr = ssock.accept()
    
            print('Peer Certificate:')
            pprint(conn.getpeercert())

            data = conn.read(1024)
            print('Received:', data)
            conn.write(data)
