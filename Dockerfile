# Pins working nginx version image
FROM nginx:1.23.3

# Copies in "Hello World!" index.html 
RUN echo \
"<html> \
<head> \
<title>Hello World</title> \
</head> \
<body> \
<h1>Hello World!</h1> \
</body> \
</html>" \
> /usr/share/nginx/html/index.html
