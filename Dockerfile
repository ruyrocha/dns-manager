FROM ruby:2.6.3-buster

RUN gem update --system
RUN gem install bundler
# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

# Install Node.js 8.x
RUN /bin/bash -c 'bash <(curl -sL https://deb.nodesource.com/setup_8.x)' \
  && apt install -y --no-install-recommends \
     nodejs \
     postgresql-client \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./

RUN BUNDLE_JOBS=4 bundle install

COPY . .

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0", "-p", "3000"]
