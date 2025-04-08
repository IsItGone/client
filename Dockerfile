FROM nginx:stable-alpine

LABEL authors="ddodongit"

COPY build/web/ /app

RUN cat > /etc/nginx/conf.d/default.conf <<EOF
server {
    listen 80;
    location / {
        root /app;
    }
}
EOF

EXPOSE 80

ENTRYPOINT ["nginx", "-g", "daemon off;"]