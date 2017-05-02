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
other types of locations. In this lab, we have only the one `time_wrapper` 
cookbook. All other dependencies will be fetched from the chef supermarket.
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

When you're finished, you should see output like the following

````
Finished in 0.288 seconds (files took 2.42 seconds to load)
2 examples, 0 failures
````

### Integration Testing

Now that we have some unit tests for our time_wrapper cookbook and we're more
confident in it, let's move on to integration tests.

In our fictional scenario, we have some `server` role and we want to set the
timezone and install NTP. Looking at the `server.rb` file confirms that's what
we're trying to do. But we want to verify that, after convergence is complete,
everything is as we expect. Specifically, we want the instance to:

* have the correct timezone set according to both `/etc/sysconfig/clock` and
  `/etc/localtime`
* have the `ntpd` service be installed and enabled

Like with unit testing, let's see what the state of our integration tests are.
Unlike unit tests, which are specific to a cookbook, our integration tests will
function on roles. The test files are located in `test/integration`, which is
the default structure expected by Test-Kitchen.

Test-Kitchen reads a file called `.kitchen.yml` to configure itself. Look at 
that file to see how we're set-up. It's fully commented. Once you're done with
that, let's look at our single integration test file, `default_spec.rb`. It too
is commented, so it shouldn't be too hard to see what's going on there.

After you've looked around, let's try running these tests!

First, let's do this long-form. First, let's try converging an instance without
running any tests.

````
bundle exec kitchen converge
````

You'll see a LOT of output where it downloads a docker image, installs Chef,
uses Berkshelf to resolve and upload all cookbook dependencies to the instance 
and finally converges the instance. Everything should converge successfully, and 
then you'll see something like

````
       Chef Client finished, 9/15 resources updated in 03 seconds
       Finished converging <default-centos6> (0m11.27s).
````

Now let's run our tests

````
bundle exec kitchen verify
````

You should see output similar to

````
  File /etc/sysconfig/clock
     ✔  should exist
     ✔  should be file
     ✔  content should match "ZONE=\"US/Pacific\"\nUTC=true"
  test /etc/localtime
     ↺  Write a test which verifies
     /etc/localtime
     * exists,
     * is a file,
     * is a symlink,
     * and is symlinked to the expected timezone file in /usr/share/zoneinfo
  Service ntpd
     ✔  should be installed
     ✔  should be enabled

Test Summary: 5 successful, 0 failures, 1 skipped
       Finished verifying <default-centos6> (0m0.29s).
````

which tells us that one of our tests isn't finished yet.

To clean up, let's do

````
bundle exec kitchen destroy
````

which will tear down the instance we just created.

To destroy, converge, test, and destroy again, we can do

````
bundle exec kitchen test
````

Now that we're familiar with the commands that are executing, let's fix that 
test! Following the instructions in the comments of the `default_spec.rb` file,
flesh out the unfinished test. <https://www.inspec.io/docs/reference/resources/>
will probably be helpful, and remember that there's a possible solution in the
`chef-testing-lab-final` directory.

`bundle exec kitchen test` is pretty short, but there's also rake tasks to run
the tests as well. `bundle exec rake kitchen:all` or 
`bundle exec rake kitchen:default-centos6`. You can use `bundle exec rake -T`
to list all the rake tasks available to you.

Once you've got the tests passing, celebrate! 

**But wait!**

We have another environment! I wonder what happens if we run those tests...

````
CHEF_ENV=stg bundle exec kitchen test
````

Looks like there's something else wrong here.

````
  File /etc/sysconfig/clock
     ✔  should exist
     ✔  should be file
     ∅  content should match "ZONE=\"Etc/UTC\"\nUTC=true"
     expected "ZONE=\"US/Eastern\"\nUTC=true" to match "ZONE=\"Etc/UTC\"\nUTC=true"
     Diff:
     @@ -1,3 +1,3 @@
     -ZONE="Etc/UTC"
     +ZONE="US/Eastern"
      UTC=true
````

So what happened? Let's take a look at our test. The expectation we define
uses a test attribute defined in `ENVIRONMENT-attributes.yml`. What's in
`dev-attributes` vs `stg-attributes`? Looks like our tests have said we expect
dev to be in `US/Pacific` and stg in `Etc/UTC`. Our unit tests have told us that
our cookbook should work correctly if given the right attribute values, so maybe
there's something wrong in the environment files.

And, sure enough, if we look in `stg.json`, we can see that we've made a mistake
and set the timezone to `US/Eastern`. Change that value to `Etc/UTC` and re-run
the tests. They should all pass now.

And now we have a working cookbook and role with correct configuration!

## Conclusion

Now you've seen:

* How to unit test using chefspec
* How to integration test with Inspec and Test-Kitchen
* Some supporting tools that make it all happen

These tools have a lot of power and flexibility, and they don't have to be used
in exactly the way shown here. Hopefully you feel more confident now to take
what you've learned and adapt it to some real code!

[1]: https://www.vagrantup.com/
[2]: https://www.virtualbox.org/wiki/Downloads
[3]: https://github.com/test-kitchen/test-kitchen
[4]: https://github.com/sethvargo/chefspec
[5]: https://github.com/chef/inspec
[6]: http://berkshelf.com/v2.0/
[7]: https://bundler.io/
[8]: https://ruby.github.io/rake/
[9]: http://rspec.info/