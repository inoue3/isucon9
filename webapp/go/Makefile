export GO111MODULE=on

all: isucari

isucari: *.go
	go build -o isucari

prod-isucari:
	GOOS=linux GOARCH=amd64 go build -o prod-isucari
