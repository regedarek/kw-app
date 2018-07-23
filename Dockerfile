FROM ruby:2.4.1-alpine

RUN apk update
RUN apk add --update build-base nodejs postgresql-dev tzdata git imagemagick

ENV app /usr/src/kw-app/
RUN mkdir $app
WORKDIR $app

ENV BUNDLE_PATH /gems

ADD . $app

EXPOSE 3001

CMD rm -f tmp/pids/server.pid && bundle exec rails s -p 3002 -b 0.0.0.0
