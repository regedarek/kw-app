FROM ruby:2.7.0-alpine3.11

RUN apk update
RUN apk upgrade
RUN apk add --update build-base nodejs postgresql-dev tzdata git imagemagick gcompat libxml2-dev curl-dev yarn libsodium-dev
RUN apk update && apk add -u yarn

ENV app /usr/src/kw-app/
RUN mkdir $app
WORKDIR $app

ENV BUNDLER_VERSION 2.2.15
ENV BUNDLE_PATH /kw-app-gems

RUN gem install bundler -v 2.2.15
RUN bundle config --global github.https true

ADD . $app

EXPOSE 3002

CMD rm -f tmp/pids/server.pid && bundle exec rails s -p 3002 -b 0.0.0.0
