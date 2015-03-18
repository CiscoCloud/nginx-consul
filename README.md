

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
