FROM node:18.10.0-alpine3.15
WORKDIR /app
COPY package.json ./
RUN npm install
COPY . .
EXPOSE 8000
CMD [ "node", "src/server.js" ]
