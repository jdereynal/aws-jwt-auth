# AWS JWT Authorizer
An AWS API Gateway custom authorizer to validate JWTs created by BYU's WSO2.

## Usage
- If you are in the NotifyMe AWS domain (https://notify-me-byu.signin.aws.amazon.com)
    + You just need to [add a custom authorizer](#add-a-custom-authorizer) for your api.
- If you are not in the NotifyMe AWS domain
    + First you'll need to [create a lambda function](#create-a-lambda-function) called `verifyWSO2JWT`.
    + Then [add a custom authorizer](#add-a-custom-authorizer) for your api.

### Create A Lambda Function

### Add A Custom Authorizer
You'll need to add the `verifyWSO2JWT` lambda function as a custom authorizer for your api.

1. From the Aamazon AWS Console home, click on "API Gateway".
2. Click on the API for which you would like to add the custom authorizer.
3. Click on the "Resources" tab to the right of your API name.
4. Select "Custom Authorizers" in the list that appears.
    + **You should see a form that looks like this**:
    ![image](https://cloud.githubusercontent.com/assets/281637/13755808/8ed15406-e9e2-11e5-9a06-733126664468.png)
5. Fill out all the required fields. (Denoted by an *).
6. 