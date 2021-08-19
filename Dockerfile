FROM node:14.17.3-alpine

WORKDIR /app

# スクリプトに変更があっても、bundle installをキャッシュさせる
COPY ["package.json", "yarn.lock", "/app/"]
RUN yarn install

COPY . /app/

# 長期に実行している ENTRYPOINT の実行バイナリに対し、 docker stop で適切にシグナルを送るには、 exec で起動する必要がある
ENTRYPOINT exec node broadcast_status_server.js
