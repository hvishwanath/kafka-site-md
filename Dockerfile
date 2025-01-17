FROM nginx:alpine

# Copy the locally generated site to the Nginx html directory
COPY ./public /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx
ENTRYPOINT ["nginx", "-g", "daemon off;"]