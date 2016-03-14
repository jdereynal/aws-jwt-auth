#!/usr/bin/env bash

PIPELINE=WSO2 JWT Custom Authorizer
BUCKET=verify-wso2-jwt-lambda-versions
LAMBDA_FUNCTION_REGION=us-west-2
LAMBDA_FUNCTION=verifyWSO2JWT

pipeline() {
    # If our deployment environment file doesnt exist already, create it.
    if [ ! -f /tmp/aws-deployment.env ]; then
        touch /tmp/aws-deployment.env
        # heredoc indentation has to be done with tabs, since this file is indented using
        # spaces, the heredoc is not indented at the correct level at the moment.
        cat << EOF > /tmp/aws-deployment.env
REPO_NAME=$PIPELINE
SLACK_INCOMING_WEBHOOK_URL=$SLACK_INCOMING_WEBHOOK_URL
CI_COMMIT_MESSAGE=$(git show -s --format=%s $CIRCLE_SHA1)
CI_COMMIT_ID=$CIRCLE_SHA1
EOF
    fi

    case "$1" in
        start)
            say "$PIPELINE deployment started." && \
            LAST_WORKING_PRODUCTION_LAMBDA_VERSION=$(aws lambda get-alias \
                --region $LAMBDA_FUNCTION_REGION \
                --function-name $LAMBDA_FUNCTION \
                --name PROD \
                --query FunctionVersion) && \
                echo -n "$LAST_WORKING_PRODUCTION_LAMBDA_VERSION" > /tmp/last-working-production-lambda-version
            if [ "$?" -ne 0 ]; then
                __write_failure_msg "Error while attempting to initialize pipeline. Previous DEV and PROD lambda aliases will remain in place."
                return 1
            fi
            ;;
        deploy)
            # Put new version of lambda out.
            cp $LAMBDA_FUNCTION.js index.js && \
            zip -r $CIRCLE_SHA1 index.js && \
            aws s3 cp $CIRCLE_SHA1.zip s3://$BUCKET && \
            VERSION_TO_RELEASE_IF_SUCCESSFUL=$(aws lambda update-function-code \
                --region $LAMBDA_FUNCTION_REGION \
                --function-name $LAMBDA_FUNCTION \
                --publish \
                --s3-bucket $BUCKET \
                --s3-key $CIRCLE_SHA1.zip \
                --query Version) && \
                echo -n "$VERSION_TO_RELEASE_IF_SUCCESSFUL" > /tmp/new-lambda-version
            if [ "$?" -ne 0 ]; then
                __write_failure_msg "Error while attempting to deploy new version to DEV lambda alias. Previous DEV alias will remain in place."
                return 1
            fi
            ;;
        run-tests)
            shift
            run-tests "$@"
            ;;
        release)
            # Update prod lambda alias to new version.
            aws lambda update-alias \
                --region $LAMBDA_FUNCTION_REGION \
                --function-name $LAMBDA_FUNCTION \
                --name PROD \
                --function-version $(cat /tmp/new-lambda-version | tr -d '"')
            if [ "$?" -ne 0 ]; then
                __write_failure_msg "Error while attempting to update lambda PROD alias. Previous PROD alias will remain in place."
                return 1
            fi
            ;;
        rollback)
            # Update prod lambda alias to last working version.
            aws lambda update-alias \
                --region $LAMBDA_FUNCTION_REGION \
                --function-name $LAMBDA_FUNCTION \
                --name PROD \
                --function-version $(cat /tmp/last-working-production-lambda-version | tr -d '"')
            __write_failure_msg "NotifyMe pipeline production tests failed. Rolled back PROD lambda alias to last working version."
            return 0
            ;;
        finish)
            say "$PIPELINE deployment finished succesfully."
            if [ "$?" -ne 0 ]; then
                __write_failure_msg "Error while attempting finish pipeline succesfully."
                return 1
            fi
            return 0
            ;;
        fail)
            say "$(cat /tmp/pipeline-fail-msg)"
            return 1
            ;;
        *)
            __write_failure_msg "Invalid pipeline command: $1"
            return 1
            ;;
    esac
}

say() {
    docker run --env-file /tmp/aws-deployment.env -v /tmp:/tmp quay.io/byuoit/aws-deployment slack_say "$@"
}

run-tests() {
    return 0
}

__write_failure_msg() {
    echo -n "$@" > /tmp/pipeline-fail-msg
    echo -n " " >> /tmp/pipeline-fail-msg
    echo -n "Check $CIRCLE_BUILD_URL for details." >> /tmp/pipeline-fail-msg
    return 1
}

if pipeline "$@"; then
    exit 0
else
    exit 1
fi
