FROM node:20.15.1-alpine
LABEL author="Goke Pelemo"

# Install dependencies and build the application
RUN apk add --no-cache git nodejs npm s3cmd
RUN npm install -g pm2
RUN git clone ${CODE_REPOSITORY} /var/www
WORKDIR /var/www
RUN chmod -R 777 uploads/images
RUN npm install
RUN npm run build

# Run the application
CMD ["pm2", "start", "server.js", "--name", "${APP_NAME}"]

# Expose the port the app runs on
EXPOSE 3001