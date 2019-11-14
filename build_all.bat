docker build -t oracle:11.2.0.3 ./oracle-11.2.0.3 && ^
docker build -t oracle:sits-9.7.0 ./oracle-sits-9.7.0 && ^
docker build -t sits:9.7.0-app ./sits-9.7.0-app && ^
docker build -t sits:9.7.0-webapp ./sits-9.7.0-webapp && ^
docker build -t sits:9.7.0-web ./sits-9.7.0-web && ^
docker system prune -f && ^
docker volume prune -f
