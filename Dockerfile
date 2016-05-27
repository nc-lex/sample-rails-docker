# Base our image on an official, minimal image of our preferred Ruby
FROM ruby:2.2-slim

# Install essential Linux packages
RUN apt-get update -qq && apt-get install -y build-essential

# Prevent bundler warnings; ensure that the bundler version executed is >= that which created Gemfile.lock
RUN gem install bundler

# Set our working directory to a temporary location for a minimal Rails install
WORKDIR /tmp

# Use the minimal Gemfiles in .docker as Docker cache markers
COPY .docker/Gemfile Gemfile
COPY .docker/Gemfile.lock Gemfile.lock

# Install essential Rails gems
RUN bundle install

# Install additional Linux packages that will be used in the actual Gemfile
RUN apt-get install -y mysql-client libmysqlclient-dev
# RUN apt-get install -y libpq-dev

# Define where our application will live inside the image
ENV RAILS_ROOT /var/www/sample_app

# Create application home. App server will need the pids dir so just create everything in one shot
RUN mkdir -p $RAILS_ROOT/tmp/pids

# Set our working directory to application home
WORKDIR $RAILS_ROOT

# Use the actual Gemfiles as Docker cache markers. Always bundle before copying app src
# (the src likely changed and we don't want to invalidate Docker's cache too early)
# http://ilikestuffblog.com/2014/01/06/how-to-skip-bundle-install-when-deploying-a-rails-app-to-docker/
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock

# Install additional Ruby gems
RUN bundle install

# Copy the Rails application into place
COPY . .
