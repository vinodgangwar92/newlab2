# Use official lightweight NGINX image
FROM nginx:alpine

# Copy all local site files into the NGINX html directory
COPY . /usr/share/nginx/html

# Expose port 80 (web)
EXPOSE 80

# Start NGINX when container starts
CMD ["nginx", "-g", "daemon off;"]
