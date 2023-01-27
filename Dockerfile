FROM nginx

# Update repositories and install openssl so an SSL cert can be generated for HTTPS
RUN apt-get update && apt-get install -y openssl

# Generates an SSL cert for the host's public IP that it gets from checkip.amazonaws.com
RUN IP_ADDRESS=$(curl checkip.amazonaws.com) && openssl req -x509 -nodes -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt -subj "/CN=$IP_ADDRESS"

# Configures nginx to throw 301 (redirect to HTTPS) when HTTP on port 80 is hit
# Also declares the location of the generated SSL for HTTPS 
RUN echo "server { \
    listen 0.0.0.0:80; \
    listen [::]:80; \
    return 301 https://$host$request_uri; \
} \
\
server { \
    listen 0.0.0.0:443 ssl; \
    ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt; \
    ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key; \
\
    location / { \
        root /usr/share/nginx/html; \
        index index.html index.htm; \
    } \
}" > /etc/nginx/conf.d/default.conf

# Saves the "Hello World" file as index.html 
RUN echo "<html> \
<head> \
<title>Hello World</title> \
</head> \
<body> \
<h1>Hello World!</h1> \
</body> \
</html>" > /usr/share/nginx/html/index.html
