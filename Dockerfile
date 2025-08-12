# nginxdemos/hello 기반으로 아주 얇게 커스터마이즈
FROM nginxdemos/hello:latest

# 보여줄 메시지 덮어쓰기 (정적 페이지 교체)
COPY index.html /usr/share/nginx/html/index.html
