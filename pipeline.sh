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
            # Update lambda version.
            # Sticking the byuawsjwtauthorizer.zip inside of the release-staging folder on lines
            # 46 & 47, and then extracting it back out on line 53 preserves the local version,
            # which is the one we want to keep and push out to the release branch in the first place.
            # Git will complain if you try to checkout a branch that would overwrite your local changes anyway.
            mkdir lambda-deployment-package && \
            cp package.json lambda-deployment-package/ && \
            cp index.js lambda-deployment-package/ && \
            cp README.md lambda-deployment-package/ && \
            cd lambda-deployment-package/ && \
            npm install && \
            rm README.md && \
            rm package.json && \
            zip -r ../$CIRCLE_SHA1 . && \
            cd - && \
            rm -rf lambda-deployment-package/ && \
            cp $CIRCLE_SHA1.zip latest.zip && \
            cp latest.zip byuawsjwtauthorizer.zip && \
            mkdir release-staging && \
            mv byuawsjwtauthorizer.zip release-staging/ && \
            git config user.name "CircleCI Deployment Bot" && \
            git config user.email "circleci@byu-oit-appdev/aws-jwt-auth" && \
            git config push.default simple && \
            git checkout -b release origin/release && \
            git pull --rebase && \
            mv release-staging/byuawsjwtauthorizer.zip . && \
            git add byuawsjwtauthorizer.zip && \
            git commit -m "Release new version: $CIRCLE_SHA1" && \
            git push && \
            aws s3 cp $CIRCLE_SHA1.zip s3://$BUCKET && \
            aws s3 cp latest.zip s3://$BUCKET && \
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
