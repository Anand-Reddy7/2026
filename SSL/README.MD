# SSL

## Multiple SSL Providers

1.  DigiCert	
2.	Sectigo	
3.	Let's Encrypt	
4.	GlobalSign
5.	Google

## What is an SSL certificate?

An SSL certificate, more accurately a TLS certificate, is a digital certificate used to establish the identity of a server and enable encrypted communication between the client and server. It contains information such as the server's domain name, public key, issuer CA, validity period, and digital signature from the CA.

```text
Client
   |
   | HTTPS
   ↓
Server
   |
   └── Server Certificate
          |
          ├── Domain: api.example.com
          ├── Public Key
          ├── Issuer: Intermediate CA
          ├── Valid From / To
          └── CA Digital Signature
```

## How does TLS handshake happen?

```text
        CLIENT                              SERVER
           |                                  |
           |------ ClientHello -------------->|
           |                                  |
           |<----- ServerHello ---------------|
           |<----- Certificate ---------------|
           |<----- Key Exchange --------------|
           |                                  |
           |------ Key Exchange ------------->|
           |                                  |
           |   Verify Certificate             |
           |   Establish Session Key          |
           |                                  |
           |====== Encrypted Communication ===>|
```

