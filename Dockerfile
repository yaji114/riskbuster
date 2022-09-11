FROM ruby:3.0.0

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
  && curl -sL https://deb.nodesource.com/setup_16.x | bash - && apt-get install -y nodejs \
  && apt-get update -qq \
  && apt-get -y install \
  yarn \
  nodejs \
  imagemagick \
  default-mysql-server \
  default-mysql-client

WORKDIR /riskbuster

COPY Gemfile /riskbuster/Gemfile
COPY Gemfile.lock /riskbuster/Gemfile.lock

RUN gem install bundler
RUN bundle install

RUN mkdir -p tmp/sockets
