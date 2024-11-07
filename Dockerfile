# Start from a Go base image
FROM golang:1.20

# Set the working directory
WORKDIR /app

# Copy the Go module files and download dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy the source code into the Docker image
COPY . .

# Run tests
CMD ["go", "test", "-race", "-coverprofile=coverage.out", "-covermode=atomic"]
