FROM node:18-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm install

# Copy code and .env for build
COPY . .

# Use the .env file during build
RUN npm run build

# Production stage using tiny Nginx image
FROM nginx:alpine AS production

# Copy the static build files from build stage
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy our custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Nginx runs on port 80 by default
EXPOSE 80

# Use default nginx command
CMD ["nginx", "-g", "daemon off;"]