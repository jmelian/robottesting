#From robot:melian
From robottesting:melian

ENV ROBOT_WORK_DIR /robotTesting
ENV ROBOT_RESULTS_DIR /robotTesting/results
ENV VIM_NAME malagacore

RUN apt-get update && apt-get install -qq -y \
  build-essential libpq-dev --no-install-recommends




WORKDIR ${ROBOT_WORK_DIR}

COPY . .

VOLUME ./testsuite ${ROBOT_WORK_DIR}/testsuite

# Port for the web reports
EXPOSE 80

# Restart the web service for the logs
ENTRYPOINT sed 's@\/home@'"$ROBOT_RESULTS_DIR"'@g' /etc/lighttpd/lighttpd.conf > /etc/lighttpd/lighttpd.conf2 && mv /etc/lighttpd/lighttpd.conf2 /etc/lighttpd/lighttpd.conf && service lighttpd restart && /bin/bash

# Execute all robot tests
#CMD ["run-tests-in-virtual-screen.sh"]
