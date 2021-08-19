const http = require('http');
const url = require('url');
const querystring = require('querystring');
const puppeteer = require('puppeteer');

const checkBroadcast = (async (user_url) => {
  const browser = await puppeteer.launch({
    args: [
      '--disable-gpu',
      '--disable-dev-shm-usage',
      '--disable-setuid-sandbox',
      '--no-first-run',
      '--no-sandbox',
      '--no-zygote',
      '--single-process'
    ]
  });
  // const browser = await puppeteer.launch({ headless: false });

  const page = await browser.newPage();
  await page.goto(user_url, {waitUntil: ['load', 'networkidle2']});

  const player = await page.$("#mildom-player-video-area")
  // const liveEnd = await page.$(".liveEndTop");
  // console.log(player)
  // console.log(player ? "YES": "NO")

  await browser.close();

  return player;
})

http.createServer(async (req, res) => {
  const query = url.parse(req.url, true).query

  const user_id = query.user_id
  if (!user_id) {
    res.writeHead(400, {'Content-Type': 'text/plain'});
    res.end("No user_id specified");
    return 
  }

  const api_key = query.api_key
  if (api_key !== process.env.API_KEY) {
    res.writeHead(400, {'Content-Type': 'text/plain'});
    res.end("api_key is not valid");
    return 
  }

  const user_url = `https://www.mildom.com/${user_id}`

  res.writeHead(200, {'Content-Type': 'text/plain'});
  const status = await checkBroadcast(user_url);
  res.end(`{"user_id": ${user_id}, "broadcasting": ${status ? "true" : "false"}}`);
}).listen(process.env.PORT, () => console.log(`Server http://localhost:${process.env.PORT}`));
