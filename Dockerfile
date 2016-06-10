# TODO #1
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

# TODO #2
# Define where our application will live inside the image
ENV RAILS_ROOT /var/www/sample_app

# Create application home. App server will need the pids dir so just create everything in one shot
RUN mkdir -p $RAILS_ROOT/tmp/pids

# Set our working directory to application home
WORKDIR $RAILS_ROOT

# TODO #3
# Install additional Linux packages
# RUN apt-get update -qq && apt-get install -y libxslt-dev libxml2-dev            # nokogiri, < 1.6.4
RUN apt-get update -qq && apt-get install -y mysql-client libmysqlclient-dev    # mysql2
# RUN apt-get update -qq && apt-get install -y libpq-dev                          # pg
RUN apt-get update -qq && apt-get install -y vim                                # vim
RUN apt-get update -qq && apt-get install -y git                                # git

# TODO #4
# Tweak the system for some particular gem install errorså
# RUN gem update debugger-ruby_core_source
# RUN gem install debugger -v '1.6.5'

# Use the actual Gemfiles as Docker cache markers. Always bundle before copying app src
# (the src likely changed and we don't want to invalidate Docker's cache too early)
# http://ilikestuffblog.com/2014/01/06/how-to-skip-bundle-install-when-deploying-a-rails-app-to-docker/
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
# COPY vendor/cache vendor/cache

# Install additional Ruby gems
RUN bundle install

# Set some aliases
RUN echo "alias be='bundle exec'" >> ~/.bashrc

# Copy the Rails application into place
COPY . .

# Start an interactive shell
CMD [ "/bin/bash" ]
