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
5. Fill out the information for the custom authorizer.
    + `Name`: This can be anything you want.
    + `Lambda region`: The region in which you created your lambda function. If you are in the NotifyMe AWS domain, the region is `us-west-2` .
    + `Lambda function`: The name of the your lambda function. If you followed [the instructions for creating a lambda function](#create-a-lambda-function) or you are in the NotifyMe AWS domain, the function name is `verifyWSO2JWT` .
    + `Execution Role`: Leave this blank.
    + `Identity token source`: The location of the JWT in the client request. BYU WSO2 sticks this in the `X-JWT-Assertion` header, so the identity token source would be: `method.request.header.X-JWT-Assertion`.
    + `Token validatin expression`: An optional regular expression you can specify that API Gateway will use to validate the incoming JWT before it is passed to your custom authorizer. Specify one if you want, but leaving it blank is totally fine.
    + `Result TTL in seconds`: How long API Gateway should cache the response from your custom authorizer for a particular JWT. Defaults to 300 seconds. You can change this value to something that makes more sense for your API or just leave it as is.
6. Click "Create" in the bottom right-hand corner of the console.