# AWS JWT Authorizer
An AWS API Gateway custom authorizer to validate JWTs created by BYU's WSO2.

## Usage
- If you are in the NotifyMe AWS domain (https://notify-me-byu.signin.aws.amazon.com)
    + [Follow these instructions](#notifyme-aws-domain)
- If you are not in the NotifyMe AWS domain
    +  [Follow these instructions](#not-in-aws-domain)

### NotifyMe AWS Domain
You'll need to add the `verifyWSO2JWT` lambda function as a custom authorizer for your api.

1. From the Aamazon AWS Console home, click on "API Gateway".
2. Click on the API for which you would like to add the custom authorizer.
3. Click on the "Resources" tab to the right of your API name.
4. Select "Custom Authorizers" in the list that appears.
5. You should see a form that looks like this:
![image](https://cloud.githubusercontent.com/assets/281637/13755725/2c2434ea-e9e2-11e5-8e71-f93c22382c2c.png)

### Other AWS Domain

