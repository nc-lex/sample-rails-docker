# TODO #1
# Base our image on an official, minimal image of our preferred Ruby
FROM ruby:2.2-slim

# Install essential Linux packages
RUN apt-get update -qq && apt-get install -y build-essential

# Prevent bundler warnings; ensure that the bundler version executed is >= that which created Gemfile.lock
RUN gem install bundler



# TODO #2
# Install additional Linux packages
RUN apt-get update -qq && apt-get install -y git                                # git
RUN apt-get update -qq && apt-get install -y vim                                # vim
# RUN apt-get update -qq && apt-get install -y libxslt-dev libxml2-dev            # nokogiri, < 1.6.4
RUN apt-get update -qq && apt-get install -y mysql-client libmysqlclient-dev    # mysql2
# RUN apt-get update -qq && apt-get install -y libpq-dev                          # pg
# RUN apt-get update -qq && apt-get install -y imagemagick                        # mini_magick
RUN gem install zeus                                                            # zeus

# TODO #3
# Tweak the system for some particular gem install errorså
# RUN gem update debugger-ruby_core_source
# RUN gem install debugger -v '1.6.5'



# TODO #4
# Define where our application will live inside the image
ENV RAILS_ROOT /var/www/sample_app

# Create application home. App server will need the pids dir so just create everything in one shot
RUN mkdir -p $RAILS_ROOT/tmp/pids



# OPTIONAL #1
# See https://github.com/nc-lex/sample-rails-docker for the following three sections
# Set our working directory to a temporary location for a minimal Rails install
RUN mkdir -p /tmp/essentials
WORKDIR /tmp/essentials

# Use the minimal Gemfiles in .docker as Docker cache markers
COPY .docker/essentials/Gemfile* ./
COPY vendor/cache vendor/cache

# Install essential Rails gems
RUN bundle install --local --no-cache --no-prune
# end OPTIONAL #1



# Set our working directory to application home
WORKDIR $RAILS_ROOT

# Use the actual Gemfiles as Docker cache markers. Always bundle before copying app src
# (the src likely changed and we don't want to invalidate Docker's cache too early)
# http://ilikestuffblog.com/2014/01/06/how-to-skip-bundle-install-when-deploying-a-rails-app-to-docker/
COPY Gemfile* ./
COPY vendor/cache vendor/cache

# Install additional Ruby gems
RUN bundle install --local --no-cache --no-prune



# Make the environment more development friendly
RUN echo "alias be='bundle exec'" >> ~/.bashrc
RUN echo "export TERM=xterm" >> ~/.bashrc

# Define an entrypoint for receiving arguments
ENTRYPOINT [ ".docker/entrypoint.sh" ]

# Start an interactive shell by passing arguments to the entrypoint
CMD [ "-i" ]

# Copy the Rails application into place
COPY . .
