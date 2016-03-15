#!/usr/bin/env bash

PIPELINE="AWS JWT Custom Authorizer"
BUCKET=verify-jwt-lambda-versions
LAMBDA_FUNCTION_REGION=us-west-2
LAMBDA_FUNCTION=verifyJWT

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
            say "$PIPELINE deployment started."
            if [ "$?" -ne 0 ]; then
                __write_failure_msg "Error while attempting to initialize pipeline. Previous lambda function code will remain in place."
                return 1
            fi
            ;;
        deploy)
            # Put new version of lambda out.
            mkdir lambda-deployment-package && \
            cp package.json lambda-deployment-package/ && \
            cp index.js lambda-deployment-package/ && \
            cp README.md lambda-deployment-package/ && \
            cd lambda-deployment-package/ && \
            npm install && \
            zip -r ../$CIRCLE_SHA1 . && \
            cd - && \
            aws s3 cp $CIRCLE_SHA1.zip s3://$BUCKET && \
            aws lambda update-function-code \
                --region $LAMBDA_FUNCTION_REGION \
                --function-name $LAMBDA_FUNCTION \
                --s3-bucket $BUCKET \
                --s3-key $CIRCLE_SHA1.zip
            if [ "$?" -ne 0 ]; then
                __write_failure_msg "Error while attempting to update lambda function code. Previous lambda function code will remain in place."
                return 1
            fi
            ;;
        run-tests)
            shift
            run-tests "$@"
            ;;
        finish)
            say "$PIPELINE deployment finished succesfully."
            if [ "$?" -ne 0 ]; then
                __write_failure_msg "Error while attempting finish pipeline succesfully, but new lambda function code is in place."
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
