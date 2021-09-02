#!/bin/bash
R_ENV=${RAILS_ENV:-test}
ruby /scripts/yml_edit.rb $@ -e ${R_ENV}.password=1234 -e ${R_ENV}.username=root -e ${R_ENV}.user.port=33061 -e ${R_ENV}.host=db