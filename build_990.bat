docker build -t oracle:12.2.0.1 ./oracle-12.2.0.1 && ^
docker build -t oracle:sits_990 ./oracle-sits_990 && ^
docker build -t sits:app_990 ./sits-app_990 && ^
docker build -t sits:webapp_990 ./sits-webapp_990 && ^
docker build -t sits:web_990 ./sits-web_990 && ^
docker system prune -f && ^
docker volume prune -f
