# Use the official Node.js 16 image as the base
FROM node:16

# Set the working directory inside the container
WORKDIR /app

# Copy the server.js file into the container
COPY server.js .

# Expose port 8080 (as server.js listens on this port)
EXPOSE 8080

# Command to run the application
CMD ["node", "server.js"]
