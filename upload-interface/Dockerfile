# Stage 1: Compile and Build Angular codebase

# Use official node image as the base image
FROM node:latest as build

# Set the working directory
WORKDIR /usr/local/app

# Copy the package.json and package-lock.json files first to leverage Docker cache
COPY package*.json ./

# Install all the dependencies
RUN npm install

# Copy the rest of the source code to the app directory
COPY ./ /usr/local/app/

# Generate the build of the application
RUN npm run build


# Stage 2: Serve app with nginx server

# Use official nginx image as the base image
FROM nginx:latest

# Remove default nginx static content
RUN rm -rf /usr/share/nginx/html/*

# Copy the build output to replace the default nginx contents.
COPY --from=build /usr/local/app/dist/upload-interface /usr/share/nginx/html

# Expose port 80
EXPOSE 80
