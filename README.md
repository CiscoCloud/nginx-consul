

## Creating self-signed SSL certificates

```
openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -days 3650 -subj '/CN=nginx' -nodes

```
Make sure to mount these keys into your container using -v:

```
docker run -v /my/ssl/loc:/etc/nginx/ssl ...
```

## Running
```
docker run -v /my/ssl/loc:/etc/nginx/ssl -d --net=host  -e CONSUL_CONNECT=localhost:8500 --name nginx-proxy nginx

```

## SSL

If you have an SSL root certificate that you need to trust to connect to Consul,
mount a volume containing the PEM at `/usr/local/share/ca-certificates`
(preferable read-only). The container will pick up the certificates and enable
the relevant Consul flags at runtime.
