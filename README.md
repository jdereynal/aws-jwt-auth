# AWS JWT Authorizer
An AWS Lambda function intended to be used as an AWS API Gateway custom authorizer to verify JWTs.

## Usage
- If you are a developer at BYU and you are in the NotifyMe AWS domain (https://notify-me-byu.signin.aws.amazon.com):
    + You just need to [add a custom authorizer](#add-a-custom-authorizer) for your api.
- If you are not a developer at BYU or you not in the NotifyMe AWS domain:
    + First you'll need to [create a lambda function](#create-a-lambda-function) called `verifyJWT`.
    + Then [add a custom authorizer](#add-a-custom-authorizer) for your api.

### Create A Lambda Function

1. From the Amazon AWS Console home, click on "Lambda."
    + If you don't have any existing lambda functions:
        - You'll see the AWS Lambda welcome page. 
        - Click on "Get Started Now" in the center of the page. 
    + If you do have existing lambda functions:
        - You'll see the normal lambda landing page with the list of your lambda functions. 
        - Click on "Create a Lambda function" in the top left-hand corner of this page.
3. You'll be asked to select a blueprint (a template really) for your lambda function, just click "Skip" in the bottom right-hand corner of this page.
4. Give your function a name, description, and select "Node.js" as the runtime.
    + If you want to be able to follow [the instructions for adding a custom authorizer](#add-a-custom-authorizer) directly, name your function `verifyJWT`. Otherwise, simply replace `verifyJWT` in those instructions with your actual function name.

### Add A Custom Authorizer
You'll need to add the `verifyJWT` lambda function as a custom authorizer for your api.

1. From the Amazon AWS Console home, click on "API Gateway."
2. Click on the API for which you would like to add the custom authorizer.
3. Click on the "Resources" tab in the grey bar near the top of the console. It should be located immediately to the right of your API name.
4. Select "Custom Authorizers" in the list that appears.
    + **You should see a form that looks like this**:
    ![image](https://cloud.githubusercontent.com/assets/281637/13755808/8ed15406-e9e2-11e5-9a06-733126664468.png)
5. Fill out the information for the custom authorizer.
    + **Name**: A name for your custom authorizer. Can be anything you'd like but cannot include spaces.
    + **Lambda region**: The region in which you created your lambda function. If you are in the NotifyMe AWS domain, the region is `us-west-2` .
    + **Lambda function**: The name of the your lambda function. If you followed [the instructions for creating a lambda function](#create-a-lambda-function) or you are in the NotifyMe AWS domain, the function name is `verifyJWT` .
    + **Execution Role**: You can optionally specify a role which API Gateway will use to invoke your custom authorizer. It's fine to leave this blank.
    + **Identity token source**: The location of the token in the client request. In my environment, this in the `X-JWT-Assertion` header, so in my case the identity token source would be: `method.request.header.X-JWT-Assertion`.
    + **Token validation expression**: An optional regular expression you can specify that API Gateway will use to validate the incoming JWT before it is passed to your custom authorizer. Specify one if you want, but leaving it blank is totally fine.
    + **Result TTL in seconds**: How long API Gateway should cache the response from your custom authorizer for a particular JWT. Defaults to 300 seconds. You can change this value to something that makes more sense for your API or just leave it as is.
6. Once you are done entering the information, click "Create" in the bottom right-hand corner of the console. If any errors occur, adjust your custom authorizer information accordingly and click "Create" again.
7. A modal will display telling you that you are about to give API Gateway permission to invoke your specified lambda function. Click "OK" in the bototm right-hand corner of the modal.
8. Now that we have created the custom authorizer, we need to attach it to the method(s) in our API where we wish to use it. Click on the "Custom Authorizers" tab in the in the grey bar near the top of the console. It should be located immediately to the right of your API Name.
9. Select "Resources" in the list that appears.
10. In the Resources menu on the left, select the HTTP method for which you want to use the custom authorizer.
11. Click on "Method Request."
12. Under "Authorization Settings", click on the pencil icon to the right of "Authoriztion."
13. Select your custom authorizer in the dropdown menu.
14. Click the checkmark icon to the right of the dropdown menu.
15. Repeat steps 10 - 14 for each HTTP method that you would like to use your custom authorizer.
16. Deploy your API for the custom authorizer to take effect.
