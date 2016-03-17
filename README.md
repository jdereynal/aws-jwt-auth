# These docs are currently a work in progress!

# AWS JWT Authorizer [![Build Status](https://circleci.com/gh/byu-oit-appdev/aws-jwt-auth.svg?style=shield)](https://circleci.com/gh/byu-oit-appdev/aws-jwt-auth)

An AWS Lambda function intended to be used as an AWS API Gateway custom authorizer to verify JWTs.

## Usage

- If you are a developer at BYU and you are in the NotifyMe AWS domain (https://notify-me-byu.signin.aws.amazon.com):
    + You just need to [add a custom authorizer](#add-a-custom-authorizer) for your api.
- If you are not a developer at BYU or you not in the NotifyMe AWS domain:
    + First you'll need to [create a lambda function](#create-a-lambda-function) called `verifyJWT`.
    + Then [add a custom authorizer](#add-a-custom-authorizer) for your api.

### Create A Lambda Function

**Note**: We will be using the AWS CLI to create our lambda function, but you could also do so through the AWS console.

1. Checkout a local copy of this repository.
2. From the repository root, checkout the release branch: `git checkout -b release origin/release`.
3. Unzip the deployment package: `unzip awsjwtauthorizer.zip`.
4. Add the key/secret you will use to verify your JWTs to `authorizer.yml`.
5. Run `make`.
6. Create the lambda function using the deployment packge:
```bash
aws lambda create-function \
    --function-name verifyJWT \
    --runtime nodejs \
    --role <your_lambda_execution_role_arn> \
    --handler index.handler \
    --zip-file fileb://awsjwtauthorizer.zip \
    --description "A lambda function for verifying JWTs"
```

### Add A Custom Authorizer

**Note**: We will be using the AWS CLI to add our custom authorizer to our API, but you could also do so through the AWS console.

1. Create the authorizer for your API:
```bash
aws apigateway create-authorizer \
--rest-api-id <your_rest_api_id> # You can get the id for your rest api from `aws apigateway get-rest-apis`
--name verify-jwt
--type TOKEN
--authorizer-uri <your_authorizer_uri> # This will look something like arn:aws:apigateway:{region}:lambda:path/2015-03-31/functions/[FunctionARN]/invokations. Replace {region} with the aws region where your API exists. You can get your function arn from `aws lambda get-function --function-name verifyJWT`
--identity-source <your_identity_source> # Should look something like `method.request.header.Name-Of-Your-Authorization-Header`
```
