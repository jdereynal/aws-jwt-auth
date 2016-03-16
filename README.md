# AWS JWT Authorizer
An AWS Lambda function intended to be used as an AWS API Gateway custom authorizer to verify JWTs.

## Usage
- If you are a developer at BYU and you are in the NotifyMe AWS domain (https://notify-me-byu.signin.aws.amazon.com):
    + You just need to [add a custom authorizer](#add-a-custom-authorizer) for your api.
- If you are not a developer at BYU or you not in the NotifyMe AWS domain:
    + First you'll need to [create a lambda function](#create-a-lambda-function) called `verifyJWT`.
    + Then [add a custom authorizer](#add-a-custom-authorizer) for your api.

### Create A Lambda Function
1. Checkout a local copy of this repository.
2. Sign into the Amazon AWS Console.
3. From the Amazon AWS Console home, click on "Lambda."
    + If you do not have any existing lambda functions:
        - You will see the AWS Lambda welcome page. 
        - Click on "Get Started Now" in the center of the page. 
    + If you do have existing lambda functions:
        - You will see the normal lambda landing page with the list of your lambda functions.
        - Click on "Create a Lambda function" in the top left-hand corner of this page.
4. You will be asked to select a blueprint (a template really) for your lambda function, just click "Skip" in the bottom right-hand corner of this page.
5. Give your function a name, description, and select "Node.js" as the runtime.
    + **Note**: If you want to be able to follow [the instructions for adding a custom authorizer](#add-a-custom-authorizer) directly, name your function `verifyJWT`. Otherwise, simply replace `verifyJWT` in those instructions with your actual function name.
6. Under "Lambda function code":
    + Click "Upload a .ZIP file"
    + In the red box that appears, click the "Upload" button.
    + Select the "lambda.zip" file located in the root of this repository.
7. A few more sections should have appeared on the page. Under "Lambda function handler and role":
    + **Handler**: Should contain `index.handler`. If not, change it to contain `index.handler`.
    + **Role**: Select or create an execution role. If you are unsure of what execution role you'd like to use, create a new role by selecting "* Basic execution role" from the menu. This will open up a new page to create the role. Give your role a name and click "Allow" in the bottom right-hand corner of the page. You will then be taken back to the lambda creation page with your new role selected in the role menu.
8. Under "Advanced Settings" you can optionally configure you lambda function with a different memory or timeout setting, as well as specify a VPC in which your lambda should be able to access resources.
    + **Memory**: 256 (MB) should be totally fine.
    + **Timeout**: You should not need to set this to higher than 1 or 2 seconds. If you find that you need to, [open an issue](https://github.com/byu-oit-appdev/aws-jwt-auth/issues/new) so that together we can better the function's performance.
    + **VPC**: Since this lambda function is intended to act as an AWS API Gateway custom authorizer, we don't need to do or access anything inside a VPC, just select "No VPC."
9. Click "Next" in the bottom right-hand corner.
    + If any errors occur after you click "Next," adjust any neccesary fields and click "Next" again.
10. You will be asked to review your Lambda function details. Click "Create function" to finish the process and actually create your lambda function.
11. Awesome! You have now created your lambda function. Now you just need to [add the lambda function as a custom authorizer](#add-a-custom-authorizer) in our API.
    + **Important**: You will probably need to modify the lambda function to fit your needs. The prepackaged `lamda.zip` in this repository is built to verify JWT's that are generated and signed by BYU's WSO2 API Gateway. If you are not at BYU and/or your JWT's are generated and signed by anything else, you will need to modify `index.js` to verify your JWTs, then create a lambda deployment package and upload it as described in [Amazon's documentation](http://docs.aws.amazon.com/lambda/latest/dg/nodejs-create-deployment-pkg.html). Even so, you can still continue on in the instructiolns and use the prepackaged `lambda.zip` as your lambda function's source just so you can kick the tires and create a custom authorizer for your API to get a feel for how it works. You will obviously still need to modify it afterward in order for it to actually work in your environment.

### Add A Custom Authorizer
You will need to add the `verifyJWT` lambda function as a custom authorizer for your api.

1. Sign into the Amazon AWS Console.
    + **Note**: If you are a developer at BYU and you are in the NotifyMe AWS domain, sign in using https://notify-me-byu.signin.aws.amazon.com.
2. From the Amazon AWS Console home, click on "API Gateway."
3. Click on the API for which you would like to add the custom authorizer.
4. Click on the "Resources" tab in the grey bar near the top of the console. It should be located immediately to the right of your API name.
5. Select "Custom Authorizers" in the list that appears.
    + **You should see a form that looks like this**:
    ![image](https://cloud.githubusercontent.com/assets/281637/13755808/8ed15406-e9e2-11e5-9a06-733126664468.png)
6. Fill out the information for the custom authorizer.
    + **Name**: A name for your custom authorizer. Can be anything you'd like but cannot include spaces.
    + **Lambda region**: The region in which you created your lambda function. If you are in the NotifyMe AWS domain, the region is `us-west-2` .
    + **Lambda function**: The name of the your lambda function. If you followed [the instructions for creating a lambda function](#create-a-lambda-function) or you are in the NotifyMe AWS domain, the function name is `verifyJWT` .
    + **Execution Role**: You can optionally specify a role which API Gateway will use to invoke your custom authorizer. It's fine to leave this blank.
    + **Identity token source**: The location of the token in the client request. In my environment, this in the `X-JWT-Assertion` header, so in my case the identity token source would be: `method.request.header.X-JWT-Assertion`.
    + **Token validation expression**: An optional regular expression you can specify that API Gateway will use to validate the incoming JWT before it is passed to your custom authorizer. Specify one if you want, but leaving it blank is totally fine.
    + **Result TTL in seconds**: How long API Gateway should cache the response from your custom authorizer for a particular JWT. Defaults to 300 seconds. You can change this value to something that makes more sense for your API or just leave it as is.
7. Once you are done entering the information, click "Create" in the bottom right-hand corner of the console. If any errors occur, adjust your custom authorizer information accordingly and click "Create" again.
8. A modal will display telling you that you are about to give API Gateway permission to invoke your specified lambda function. Click "OK" in the bototm right-hand corner of the modal.
9. Now that we have created the custom authorizer, we need to attach it to the method(s) in our API where we wish to use it. Click on the "Custom Authorizers" tab in the in the grey bar near the top of the console. It should be located immediately to the right of your API Name.
10. Select "Resources" in the list that appears.
11. In the Resources menu on the left, select the HTTP method for which you want to use the custom authorizer.
12. Click on "Method Request."
13. Under "Authorization Settings", click on the pencil icon to the right of "Authorization."
14. Select your custom authorizer in the dropdown menu.
15. Click the checkmark icon to the right of the dropdown menu.
16. Repeat steps 10 - 14 for each HTTP method that you would like to use your custom authorizer.
17. Deploy your API for the custom authorizer to take effect.
