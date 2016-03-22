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

**Note**: If you are at BYU and are validating JWTs from BYU's WSO2, you just need to do steps 1-2, and 6. You do not need to modify the deployment package with the BYU WSO2 key as that is the default.

1. Checkout a local copy of this repository.
2. From the repository root, checkout the release branch: `git checkout release`.
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
        --rest-api-id <your_rest_api_id> \
        --name verify-jwt \
        --type TOKEN \
        --authorizer-uri <your_authorizer_uri> \
        --identity-source <your_identity_source>
    ```

    + You can get the id for your rest api from `aws apigateway get-rest-apis`.
    + `authorizer-uri` will look something like: `arn:aws:apigateway:{region}:lambda:path/2015-03-31/functions/[FunctionARN]/invocations`. Replace `{region}` with the aws region where your API exists. Replace `[FunctionARN]` with your lambda function's arn. You can get your function arn from `aws lambda get-function --function-name verifyJWT`.
    + The `identity-source` should look like `method.request.header.Name-Of-Your-Authorization-Header`.

2. Add permission for the custom authorizer to invoke our lambda function:

    ```bash
    aws lambda add-permission \
        --function-name <FunctionARN> \
        --statement-id <some_unique_statement_id> \
        --action lambda:invokeFunction \
        --principal apigateway.amazonaws.com \
        --source-arn arn:aws:execute-api:{region}:{aws-account-id}:{rest-api-id}/authorizers/{authorizer-id}
    ```

    + `<FunctionARN>` is the same `FunctionARN` we used in the `create-authorizer` step.
    + `statement-id`: A unique (to this specific lambda function's policy) statment identifier.
    + `source-arn`: Replace `{region}`, `{aws-account-id}`, `{rest-api-id}`, and `{authorizer-id}` with the actual values for your authorizer. You can get your `rest-api-id` from `aws apigateway get-rest-apis`. You can get your `authorizer-id` from `aws apigateway get-authorizers --rest-api-id <rest_api_id>`

3. Now we just need to add our custom authorizer to our API methods that we want to use it:

    ```bash
    aws apigateway update-method \
        --rest-api-id <rest_api_id> \
        --resource-id <api_resource_id> \
        --http-method <api_method> \
        --patch-operations \
        "op=replace,path=/authorizationType,value=CUSTOM" \
        "op=replace,path=/authorizerId,value={authorizer-id}"
    ```

    + Replace all placeholders with their actual values.

4. Deploy your API for the changes to take effect:

    ```bash
    aws apigateway create-deployment \
        --rest-api-id <rest_api_id> \
        --stage-name <deployment_stage>
    ```

    + Replace all placeholders with their actual values.
