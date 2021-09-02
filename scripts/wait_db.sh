#!/bin/bash
HOST="${1:-mysql}"
while ! mysqladmin ping -h$HOST --silent; do sleep 1; done