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
4. Add the key/secret you will use to verify your JWTs to `config.json`.
5. Run `make`.

### Add A Custom Authorizer

**Note**: We will be using the AWS CLI to add our custom authorizer to our API, but you could also do so through the AWS console.

1. Checkout a local copy of this repository.
