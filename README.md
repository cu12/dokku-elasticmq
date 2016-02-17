# dokku elasticmq (beta)

elasticmq plugin for dokku. Currently defaults to installing [seayou/elasticmq](https://hub.docker.com/r/seayou/elasticmq/).

## requirements

- dokku 0.4.0+
- docker 1.8.x

## installation

```shell
# on 0.3.x
cd /var/lib/dokku/plugins
git clone https://github.com/cu12/dokku-elasticmq.git elasticmq
dokku plugins-install

# on 0.4.x
dokku plugin:install https://github.com/cu12/dokku-elasticmq.git elasticmq
```

## commands

```
sqs:queue:add <name> <queue>    Creates an sqs queue
sqs:create <name>               Create a sqs service with environment variables
sqs:destroy <name>              Delete the service and stop its container if there are no links left
sqs:info <name>                 Print the connection information
sqs:link <name> <app>           Link the sqs service to the app
sqs:list                        List all sqs services
sqs:topics <name>               List all sqs queues for this service
sqs:logs <name> [-t]            Print the most recent log(s) for this service
sqs:queue:remove <name> <queue> Removes an sqs queue
sqs:restart <name>              Graceful shutdown and restart of the sqs service container
sqs:start <name>                Start a previously stopped sqsq service
sqs:stop <name>                 Stop a running sqs service
```

## usage

```shell
# create a sqs service named lolipop
dokku sqs:create lolipop

# you can also specify the image and image
# version to use for the service
# it *must* be compatible with the
# official sqs image
# In fact you could any other software that is working with `aws sqs` commands
export ELASTICMQ_IMAGE="seayou/elasticmq"
export ELASTICMQ_IMAGE_VERSION="latest"

# create a sqs service
dokku sqs:create lolipop

# get connection information as follows
dokku sqs:info lolipop

# a sqs service can be linked to a
# container this will use native docker
# links via the docker-options plugin
# here we link it to our 'playground' app
# NOTE: this will restart your app
dokku sqs:link lolipop playground

The following will be set on the linked application by default
#
#   SQS_URL=http://dokku-sqs-lolipop:9200
#

# another service can be linked to your app
dokku sqs:link other_service playground

# since sqs_URL is already in use, another environment variable will be
# generated automatically
#
#   DOKKU_SQS_BLUE_URL=http://dokku-sns-other-service:9200

# you can then promote the new service to be the primary one
# NOTE: this will restart your app
dokku sqs:promote other_service playground

# this will replace sqs_URL with the url from other_service and generate
# another environment variable to hold the previous value if necessary.
# you could end up with the following for example:
#
#   SQS_URL=http://dokku-sqs-other-service:9200
#   DOKKU_SQS_BLUE_URL=http://dokku-sqs-other-service:9200
#   DOKKU_SQS_SILVER_URL=http://dokku-sqs-lolipop:9200

# you can also unlink an sqs service
# NOTE: this will restart your app and unset related environment variables
dokku sqs:unlink lolipop playground

# you can tail logs for a particular service
dokku sqs:logs lolipop
dokku sqs:logs lolipop -t # to tail

# finally, you can destroy the container
dokku sqs:destroy lolipop
```
