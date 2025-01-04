# Stage 1: Build the Hugo site
FROM hugomods/hugo:exts-0.136.5 as builder

# Set the working directory inside the container
WORKDIR /src

# Copy the entire site into the container
COPY . .

# Install npm packages
RUN npm install

RUN npm update postcss

# Build the site
RUN hugo

# Stage 2: Serve the site with Nginx
FROM nginx:alpine

# Copy the generated site from the builder stage to the Nginx html directory
COPY --from=builder /src/public /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]