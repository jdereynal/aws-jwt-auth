all:
	mkdir lambda-deployment-package
	mv index.js lambda-deployment-package/
	mv authorizer.yml lambda-deployment-package/
	mv node_modules/ lambda-deployment-package/
	cd lambda-deployment-package/ && zip -r ../awsjwtauthorizer.zip .
	rm -rf lambda-deployment-package/
