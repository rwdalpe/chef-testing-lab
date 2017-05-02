# Chef Testing Example & Lab

This lab will give a quick example of unit and integration testing chef recipes
using [ChefSpec][4] and [Inspec][5] + [Test-Kitchen][3].

You'll find two folders: `chef-testing-lab` and `chef-testing-lab-final`.

For the purposes of the lab, the code in `chef-testing-lab` is incomplete and
has at least one error. During the lab you will add some missing tests and
correct the errors. `chef-testing-lab-final` has one possible solution to the 
lab for you to look at.

## Prerequisites

### Install Vagrant and VirtualBox

Grab [Vagrant][1] and [VirtualBox][2] for your system and ensure that you can 
run both of them.

## Lab Instructions

### Start the Vagrant machine

This lab comes with a `Vagrantfile` which will create an environment with all
the tools you need to complete the lab. Simply run

````
vagrant up --provider virtualbox
````

to start the VM. It may take some time to finish provisioning. During 
provisioning the following will happen:

1. A new Ubuntu 17.04 VM will launch in virtualbox
2. Some dependencies will be installed, including:
    * git
    * ruby
    * some native build tools (for gems with native extensions)
    * docker
    * the [bundler][7] gem
3. This repository will be cloned into /home/ubuntu

### Glance Around The Lab

Let's start by looking at the structure of the lab code.

`cookbooks`: This directory contains the `time_wrapper` cookbook, which is our
sample cookbook that we wish to unit test. 

All the files inside the `time_wrapper` cookbook should be familiar to those who
have worked with a Chef cookbook before, with the exception of the `test`
directory. In that directory we will place our [ChefSpec][4] test code for the 
lab.

`environments`: This directory contains some sample environment configuraiton.
For this lab, we have two environments: dev, and stg. You'll notice that the
environments do have different configuration values!

`roles`: This directory contains our `server` role, which will apply our
`time_wrapper` recipes. We'll be writing integration tests against this role.

`test`: In the top-level `test` directory we will put our [Inspec][5] 
integration tests. It is organized in the standard Test-Kitchen format:
`test/integration/SUITE_NAME`

You'll also see several `-attribute.yml` files in this directory. Those are
Inspec attribute files, and their usage will be explained later in the lab.

`.kitchen.yml`: This is a configuration file for [Test-Kitchen][3]. 
Documentation for kitchen YAML is a bit split up, but key points can be found
at <https://docs.chef.io/config_yml_kitchen.html>. Another key thing to know
is that `.kitchen.yml` **is an ERB file** also, and so you can use environment
variables and other dynamic configuration techniques in a single YAML file.

If that isn't to your liking, you can just use CLI options to control which
YAML file will be used during kitchen runs. For this lab, we'll use a single
YAML file with dynamic properties controlled via environment variables.

`Berksfile`: [Berkshelf][6] is a dependency manager for chef cookbooks. 
Berkshelf can be told to fetch cookbooks from local paths, git repositories, and
other types of locations. In this lab, we have only the one `time_wrapper` cookbook. All other dependencies will be fetched from the chef supermarket.
If you do look at the Berkshelf documentation, you'll have to scroll for a while
to reach the Berksfile portion.

`Gemfile`: The lab will use this file to provide gem dependency pinnings via
bundler. For the lab this isn't strictly necessary, but is good practice on
instances where multiple versions of a gem may be installed.

`Rakefile.rb`: The lab uses some pre-defined [rake][8] tasks to provide
convenient wrappers around certain command sequences. The lab will always
describe such sequences in depth before introducing the rake wrappers.

### Getting Dependencies

Before we do anything else, we need to get our ruby dependencies!

From the `chef-testing-lab` directory, use bundler to install the dependencies.

````
bundle install
````

This will download and install all the gems specified in the `Gemfile`, 
respecting any version constraints given. We can also use bundler to pin our
ruby processes to those same gems. To do this, we'll be running any ruby 
commands with `bundle exec`.

### Unit Testing

Now that we have what we need, let's dive a bit deeper. The
purpose of this lab is to write integration tests for our imaginary `server`
Chef role, and unit tests against our `time_wrapper` cookbook. Let's start small
with the cookbook unit tests.

Looking at `time_wrapper` we can see that we have two recipes: `ntp` and 
`timezone`. The `ntp` recipe is just a wrapper around the `ntp` community 
cookbook, and `timezone` is mostly just a wrapper around `timezone-ii`.
`timezone` also modifies the `/etc/sysconfig/clock` file, which `timezone-ii`
does not.

We can also see that some tests are already written! There is a file called
`timezone_spec.rb` which has some content. Let's try running the tests first.
ChefSpec is an extension of [rspec][9], and it can be configured like rspec.

To run the tests:

````
# --color just makes the output a bit prettier
#
# --default-path is used here because rspec defaults to looking for a 
# diretory called 'spec' to contain test files. We're using a structure
# more similar to test-kitchen (COOKBOOK_NAME/test/unit/), so we'll override the
# default.
#
# --require ./spec_helper tells rspec to require the file 'spec_helper.rb' from 
# during every test run. We can use this spec_helper to define widely used
# common test code
bundle exec rspec --color --default-path cookbooks/*/test/unit/ --require ./spec_helper
````

When you ran that command, you likely saw output containing the following:

````
Failures:

  1) time_wrapper::timezone should test timezon-ii inclusion FIXED
     Expected pending 'Add a test which verifies the following:
* The default attributes needed by time_wrapper::timezone have correct values
* The node['tz'] and node['timezone']['use_symlink'] are correctly overridden
* The timezone-ii::default recipe is included' to fail. No Error was raised.
     # ./cookbooks/time_wrapper/test/unit/timezone_spec.rb:14

Finished in 0.25465 seconds (files took 2.39 seconds to load)
2 examples, 1 failure

Failed examples:

rspec ./cookbooks/time_wrapper/test/unit/timezone_spec.rb:14 # time_wrapper::timezone should test timezon-ii inclusion
````

So we see that there were two tests, one of which failed. Let's dig into the
test file. It's fully commented, so we should be able to understand the file by
reading through it.

And we can also see that we have our first task: adding a missing test. Using
the documentation at <https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers>, 
and <https://github.com/sethvargo/chefspec#making-assertions> you should be able
to construct a test which verifies all the requirements listed in the comments. 
Remember that you can look at a possible solution in the 
`chef-testing-lab-final` folder of this project.

Also, now that you've seen how ChefSpec is being run behind the scenes (with
rspec), it's time to introduce a convenience method! Run

````
bundle exec rake test
````

And you should see the same test output as the manual `rspec` command. Take a 
look and the `Rakefile.rb` to see where that task is defined and how it works
if you're interested. <http://www.rubydoc.info/github/rspec/rspec-core/RSpec/Core/RakeTask>
has some documentation about rspec's RakeTask class.

[1]: https://www.vagrantup.com/
[2]: https://www.virtualbox.org/wiki/Downloads
[3]: https://github.com/test-kitchen/test-kitchen
[4]: https://github.com/sethvargo/chefspec
[5]: https://github.com/chef/inspec
[6]: http://berkshelf.com/v2.0/
[7]: https://bundler.io/
[8]: https://ruby.github.io/rake/
[9]: http://rspec.info/