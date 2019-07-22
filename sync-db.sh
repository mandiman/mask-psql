#!/bin/bash

docker exec -i db bash < connect-db.sh

docker cp db:/anon.dump anon.dump

docker exec -i db rm anon.dump

#Import to staging db: docker exec -i db bash < pg_restore -U postgres -d stage anon.dump
