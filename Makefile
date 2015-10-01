
build:
	@docker build -t kokoroe/api .

push: build
	@docker push kokoroe/api
