#!/usr/bin/env bats
load test_helper

setup() {
  dokku "$PLUGIN_COMMAND_PREFIX:create" l >&2
}

teardown() {
  dokku --force "$PLUGIN_COMMAND_PREFIX:destroy" l >&2
}

@test "($PLUGIN_COMMAND_PREFIX:queue:add) error when there are no arguments" {
  run dokku "$PLUGIN_COMMAND_PREFIX:queue:add"
  assert_contains "${lines[*]}" "Please specify a name for the service"
}

@test "($PLUGIN_COMMAND_PREFIX:queue:remove) error when there are no arguments" {
  run dokku "$PLUGIN_COMMAND_PREFIX:queue:remove"
  assert_contains "${lines[*]}" "Please specify a name for the service"
}

@test "($PLUGIN_COMMAND_PREFIX:queue:add) error when service does not exist" {
  run dokku "$PLUGIN_COMMAND_PREFIX:queue:add" not_existing_service
  assert_contains "${lines[*]}" "Please specify an SQS queue name"
}

@test "($PLUGIN_COMMAND_PREFIX:queue:remove) error when service does not exist" {
  run dokku "$PLUGIN_COMMAND_PREFIX:queue:remove" not_existing_service
  assert_contains "${lines[*]}" "Please specify an SQS queue name"
}

@test "($PLUGIN_COMMAND_PREFIX:queue:list) error when service does not exist" {
  run dokku "$PLUGIN_COMMAND_PREFIX:queue:list" not_existing_service
  assert_contains "${lines[*]}" "ElasticMQ service not_existing_service does not exist"
}

@test "($PLUGIN_COMMAND_PREFIX:queue:list) success when queues are listed" {
  export ECHO_DOCKER_COMMAND="true"
  run dokku "$PLUGIN_COMMAND_PREFIX:queue:list" l
  assert_output "docker exec dokku.sqs.l /usr/bin/env sh -c AWS_ACCESS_KEY_ID=fake AWS_SECRET_ACCESS_KEY=fake AWS_DEFAULT_REGION=fake aws --endpoint-url http://dokku-sqs-l:9324 sqs list-queues --output text | cut -c11-"
}

@test "($PLUGIN_COMMAND_PREFIX:queue:add) error when queue exists" {
  run dokku "$PLUGIN_COMMAND_PREFIX:queue:add" l m
  assert_contains "${lines[*]}" "ElasticMQ service l queue already exist: m"
}

@test "($PLUGIN_COMMAND_PREFIX:queue:add) success" {
  run dokku "$PLUGIN_COMMAND_PREFIX:queue:add" l l
  assert_contains "${lines[*]}" "ElasticMQ queue created: l"
}

@test "($PLUGIN_COMMAND_PREFIX:queue:remove) error when queue does not exists" {
  run dokku "$PLUGIN_COMMAND_PREFIX:queue:remove" l l
  assert_contains "${lines[*]}" "ElasticMQ service l queue does not exist: l"
}

@test "($PLUGIN_COMMAND_PREFIX:queue:remove) success" {
  run dokku "$PLUGIN_COMMAND_PREFIX:queue:remove" l m
  assert_contains "${lines[*]}" "ElasticMQ queue deleted: m"
}
