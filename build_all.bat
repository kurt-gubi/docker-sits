docker build -t oracle:11.2.0.3 ./oracle-11.2.0.3 && ^
docker build -t oracle:12.2.0.1 ./oracle-12.2.0.1 && ^
docker build -t oracle:sits_970 ./oracle-sits_970 && ^
docker build -t oracle:sits_990 ./oracle-sits_990 && ^
docker build -t sits:app_970 ./sits-app_970 && ^
docker build -t sits:app_990 ./sits-app_990 && ^
docker build -t sits:webapp_970 ./sits-webapp_970 && ^
docker build -t sits:webapp_990 ./sits-webapp_990 && ^
docker build -t sits:web_970 ./sits-web_970 && ^
docker build -t sits:web_990 ./sits-web_990 && ^
docker system prune -f && ^
docker volume prune -f
