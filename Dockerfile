FROM alpine:3.14

# Installs latest Chromium (89) package.
RUN apk add --no-cache \
      chromium \
      nss \
      freetype \
      harfbuzz \
      ca-certificates \
      ttf-freefont \
      nodejs \
      yarn

# Tell Puppeteer to skip installing Chrome. We'll be using the installed package.
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

# Puppeteer v6.0.0 works with Chromium 89.
RUN yarn add puppeteer@6.0.0

# Add user so we don't need --no-sandbox.
RUN addgroup -S pptruser && adduser -S -g pptruser pptruser \
    && mkdir -p /home/pptruser/Downloads /app \
    && chown -R pptruser:pptruser /home/pptruser \
    && chown -R pptruser:pptruser /app

# Run everything after as non-privileged user.
USER pptruser

WORKDIR /app

# スクリプトに変更があっても、bundle installをキャッシュさせる
COPY ["package.json", "yarn.lock", "/app/"]
RUN yarn install

COPY . /app/

# 長期に実行している ENTRYPOINT の実行バイナリに対し、 docker stop で適切にシグナルを送るには、 exec で起動する必要がある
ENTRYPOINT exec node broadcast_status_server.js
