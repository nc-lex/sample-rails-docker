# Docker Environment

## Introduction to Docker

http://i.imgur.com/2c5iYX4.png

Docker is a Linux container and virtualization tool. It's more lightweight
than virtual machines, that the host Linux kernel is shared by all Docker
instances. Similar to virtual machines, each instance runs on an independent
file system. The file system of Docker is layered, allows easy management of
incremental changes and version control.

http://i.imgur.com/6xHD7Kl.png

Docker can only run on Linux kernels. Therefore, when running on OS X, Docker
runs on a minimal Linux virtual machine (created by Docker Machine).

### Vocabulary

container
:   A Docker virtualization instance.

image
:   The "base class" of containers. Defines how a container is created.
    `debian`, `ubuntu`, `ruby`, and `mysql` are among the popular images. They
    are built from steps defined in a `Dockerfile`.

Docker Engine
:   Builds and manages Docker images. Runs and manages Docker containers.

Docker Compose
:   Organize multiple Docker containers. Many of its commands resemble the
    ones of Docker Engine.

Docker Machine
:   A virtual machine tool to create a Linux environment for Docker to run on
    Windows and OS X.

Dinghy
:   A third-party tool to improve Docker on OS X. It creates its own Docker
    Machine using NFS, a faster file system than the default VirtualBox file
    sharing. It also forwards `FSEvents` on OS X to the Docker Machine.

    See "Dinghy" section under "Issues" for details about Dinghy.


## Installation

1.  Clone this repository to `~/code/docker-shared`. Run
    `.docker/scripts/install` to install Docker.

2.  Run `dinghy up` on (OS X) host machine startup (using Automator, etc.) to
    start Dinghy virtual machine.

3.  Run `eval $(dinghy env)` (in `~/.bash_profile`, etc.) to set environment
    variables for the current terminal to connect to Docker.


## Usage

*   Enter a project folder in terminal. Run `.docker/config/fetch` to fetch
    files from this repository.

*   Run `.docker/env/gen` to generate `.docker/env/*.env` files based on
    `.docker/env/*.env.example`. These files should include all configurations
    for connections between Docker containers, such as MySQL, Mongo, and Redis
    setup.

    Config `config/*.yml` according to the env files. Examples files for them
    are also provided.

*   Go to the app root directory, and run

        .docker/build -b
        .docker/start -s app

*   The app can now be accessed by `<anything>.docker:<port>`!


### Development

*   Run `.docker/bash` in another terminal tab to start a console in the app
    container for debugging, etc.

    Note that `.docker/bash db` connects to the database container. Check
    `.docker/bash -h` for details.

*   `.docker/start` will just start the container, while `.docker/start -s`
    will also initialize (using `.docker/config/init.sh`) and start the
    default server (Rails server for this project).

    Check `.docker/start -h` for details.


### Supported Projects

Currently App Server, LAC Server, and LAC Vault are supported. Run
`.docker/config/key.rb` from LAC Server to config api keys for App Server.

See "Dockerizing An Existing App" section for unsupported projects.

## Dockerizing An Existing App

### Dockerfile

`Dockerfile` defines how a single Docker image is built.

Docker caches for each line in `Dockerfile`, and will check modifications of
files and use the corresponding cache to skip steps and speed up rebuilding.
Therefore, lines that changes more often (such as `Gemfile`) should be put
after lines that changes less often (such as `apt-get install
build-essential`)

In the App Server project three Docker images are built, the minimal one for
essential and stable packages, another for the mongo server with dump files
restored, and the last for development with all required packages installed.
As long as the minimal one is not updated, building the complete one will be
much faster than building from scratch.

The minimal `Dockerfile` is placed in `.docker/images/base`:

    # TODO #1
    # Base our image on an official, minimal image of our preferred Ruby
    FROM ruby:1.9.3-slim

    # Install essential Linux packages
    RUN apt-get update -qq && apt-get install -y build-essential

    # Prevent bundler warnings; ensure that the bundler version executed is >= that which created Gemfile.lock
    RUN gem install bundler

    # TODO #2
    # Install additional Linux packages
    RUN apt-get update -qq && apt-get install -y git                                # git
    RUN apt-get update -qq && apt-get install -y vim                                # vim
    RUN apt-get update -qq && apt-get install -y libxslt-dev libxml2-dev            # nokogiri, < 1.6.4
    RUN apt-get update -qq && apt-get install -y mysql-client libmysqlclient-dev    # mysql2
    RUN apt-get update -qq && apt-get install -y libpq-dev                          # pg
    RUN apt-get update -qq && apt-get install -y imagemagick                        # mini_magick
    RUN gem install zeus                                                            # zeus

    # TODO #3
    # Tweak the system for some particular gem install errors
    RUN gem update debugger-ruby_core_source
    RUN gem install debugger -v '1.6.5'

    # TODO #4
    # Define where our application will live inside the image
    ENV HOME /root
    ENV SOURCE_ROOT $HOME/code/appserver

    # Create application home. App server will need the pids dir so just create everything in one shot
    RUN mkdir -p $SOURCE_ROOT/tmp/pids

    # TODO #5 (Optional)
    # See https://github.com/nc-lex/sample-rails-docker for the following three sections
    # Set our working directory to a temporary location for a minimal Rails install
    RUN mkdir -p /tmp/essentials
    WORKDIR /tmp/essentials

    # Use the minimal Gemfiles in .docker as Docker cache markers
    COPY Gemfile* ./
    COPY vendor/cache vendor/cache

    # Install essential Rails gems
    RUN bundle install --local --no-cache --no-prune \
      && rm -rf /tmp/essentials
    # end OPTIONAL #1

    # Set our working directory to application home
    WORKDIR $SOURCE_ROOT

    # Start an shell session
    CMD [ "/bin/bash" ]

The following are parts of the minimal `Dockerfile` that should be configured,
marked as `TODO`.

1.  `FROM ruby:1.9.3-slim` defines the base Docker image to be used. Ruby
    images can be found at https://hub.docker.com/_/ruby

2.  `RUN apt-get install -y mysql-client libmysqlclient-dev` installs native
    libraries for `mysql2` gem. Those RubyGems with native extensions may need
    this step. Tools for development can also be installed here.

3.  Sometimes `bundle install` may fail before some particular tweaks are
    made. These tweaks can be placed here.

4.  `ENV SOURCE_ROOT $HOME/code/appserver` defines where the app will run in
    the Docker container.

5.  (Optional) The essential and stable parts of the gems required by the app
    can be placed here.


### Docker Compose

`docker-compose.yml` defines how to organize multiple Docker containers as
services into a single application, and allows for additional configurations
for each container.

The following are the important labels to be configured in the file.

**links**
:   Allows connecting to another service by its service name, or an alias if
    specified.

**ports**
:   Expose ports of the container and provide mapping between ports of the
    Docker Engine (as in `dockerhost:**3003`**) and ports of the container (as
    in `rails server -p **3000`**).

    See "Usage" section for more about `dockerhost`.

    *   If a host path is specified before `:`, mounts directories of the host
        system to the container.

        See "Volume Mounting" section for issues caused by this feature.

    *   If a name is specified before `:`, mounts directories managed by
        Docker to the container, which also preserves data even if the
        container is deleted.



The following labels might also be useful.

build
:   Call `docker build` with the `Dockerfile` specified to build the image for
    the service container.

command
:   The command that will be run when the container starts. Overrides
    `COMMAND` in `Dockerfile`. Should be placed in brackets to be `exec`ed and
    keeps PID = 1.

env_file
:   The list of environment variables to be set. Sensitive strings such as
    database password can be place here.

image
:   Directly use a Docker base image without a `Dockerfile` build.


### .docker Folder

`.docker` folder includes scripts for the container entrypoint, starting
containers, starting bash sessions, synchronizing timezone, etc.

The following are files that might need configurations.

*   `.docker/config/init.sh` will be used to initialize the containers, and
    `.docker/config/server.sh` will be used to start the server.

*   `.docker/images/build` will be used to build the base images.

*   `.docker/env/*.env` are the environment variable files.


### Ignore

`.dockerignore` defines files to be excluded when copied in `Dockerfile`.
Files won't be excluded when mounted.

`.gitignore` should include `.docker/env/*.env`.

## Issues

### Volume Mounting

http://i.imgur.com/Mp8noLt.png

As shown in the graph above, Docker can mount host directories directly as
container volumes. Normally it's used to mount the source folder to avoid
`docker-compose build` after every code update on the host. Changes made by
the container (such as an update to `vendor/cache` by `bundle package`) will
also be stored by the host.

However, this creates some issues.

1.  The extra layer of Docker Machine on OS X slows the mount down. From the
    container perspective, the host directories referred here are actually
    Docker Machine folders, which are the host directories shared by Docker
    Machine through VirtualBox file sharing.

2.  The file events will not be passed by VirtualBox, so Linux file event
    interfaces (such as `inotify`) will not work.

3.  For mounted host directories, permissions on the mounted file system
    originates from the host file system, and cannot be altered by the
    container.


*   MySQL and PostgreSQL will attempt to take ownership of its data directory.
    Mounting the data directory to the host (for backing up, etc) will prevent
    them from doing so and successfully starting up.

*   However, their corresponding Docker images define their data directories
    as volumes managed by Docker, so it's easy to access it from another
    container. For example, declaring the following lines in
    `docker-compose.yml` allows the app container to access the data directory
    of the database container by the same path (e.g. `/var/lib/mysql`).

        app:
          volumes_from:
            - db

*   Run `docker volume inspect <Volume>` to find the actual volume path. They
    can be directly accessed in the virtual machine through `dinghy ssh`.


#### Dinghy

http://i.imgur.com/2SXLWxX.png

Dinghy (https://github.com/codekitchen/dinghy) addresses the first two issues.
The NFS file system allows a faster Rails loading. `FSEvents` forwarded will
trigger `inotify` for tools including zeus and guard.

### Docker Build

(`OPTIONAL` section of `Dockerfile`)

After `Gemfile` is updated, `docker-compose build` can take a long time to
finish, since all gems will be reinstalled. This can be alleviated by making a
separate `Gemfile` containing the essential and stable parts of the original
`Gemfile`. Installing the minimal `Gemfile` before the complete one will force
Docker to cache for it, so that stable gems will be skipped when reinstalling
the complete one. However, note that it can cause multiple versions of the
same gem being installed, leading to a "dirty" Docker image where `bundle
exec` is always necessary.

## Performance

Benchmarks are run to evaluate the performance of Docker containers against
native development.

Setup: Apple OS X 10.11.4, Intel Core 2 Duo 3.06GHz, 16GB DDR3, Mechanical
HDD.

### App Server Framework Loading

Command: `time echo exit | bundle exec rails console`

Average of three rounds after a warm-up round.

OS X native
:   40.86s

Dinghy
:   80.53s


### App Server Test Suite

Command: `time bundle exec rake spec`

The time in the rspec output is used to ignore the loading stage.

OS X native
:   40.25min

Dinghy
:   44.12min


### Improvement

Both spring and zeus are included in the containers and should be working.
Either of them decreases framework loading time to several seconds.

Note that `spring rake` and `zeus rake` loads the development environment
regardless of actual command (even including `rake spec` and `rake
test:prepare`).

## Tips and Troubleshooting

*   Any changes to `docker-compose.yml` may cause Docker Compose to delete and
    recreate the containers from images. Except for those to the host and
    named volumes, all changes (such as the newly installed gem libraries and
    binaries) will be lost. `.docker/build` (without `-b`) can be run
    routinely to rebuild the Docker image to include changes. It can also be
    used to "clean up" the containers.

    Note that even though `docker-compose build` will run `bundle install`,
    during this stage, changes to the context folder (such as updating
    `Gemfile.lock` and `vendor/cache`) will be made on the image's file
    system, and thus will be hidden when the context folder from the host is
    mounted by Docker Compose. Therefore, it should not be used to install new
    gems, etc.

*   The Docker Machine time and the host machine time may get out of sync,
    causing delays between file changes and Rails server reloading. Use
    `docker-machine ssh default 'sudo ntpclient -s -h pool.ntp.org'` (or
    `dinghy ssh 'sudo ntpclient -s -h pool.ntp.org'` if using Dinghy) to
    update the Docker Machine time.

    Timezone can also be different between the host machine and the Docker
    containers. `.docker/start` and `.docker/bash` will automatically update
    the container's timezone with the host machine's.

*   Occasionally the shell session behave weirdly. Run `stty sane` on the OS X
    host machine may fix the problem.

*   Run `.docker/config/init.sh -f` in the container will initialize the
    database.

*   Run `.docker/scripts/cleanup` to delete stopped containers, dangling
    images, and dangling volumes on the entire host machine. Use with caution!

*   Do not set RAILS_ENV or MYSQL_HOST in `.docker/*.env` for development and
    test.

