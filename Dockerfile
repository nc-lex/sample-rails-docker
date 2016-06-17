# Base our image on a custom image with essentials installed
FROM sample-app-base:latest



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
