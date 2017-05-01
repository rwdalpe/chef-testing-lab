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

### Looking Around The Lab

Let's start by looking at the structure of the lab code.

`cookbooks`: This directory contains the `time_wrapper` cookbook, which is our
sample cookbook that we wish to unit test. 

`environments`: This directory contains some sample environment configuraiton.
For this lab, we have two environments: dev, and stg. You'll notice that the
environments do have different configuration values!

`roles`: This directory contains our `server` role, which will apply our
`time_wrapper` recipes. We'll be writing integration tests against this role.

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

[1]: https://www.vagrantup.com/
[2]: https://www.virtualbox.org/wiki/Downloads
[3]: https://github.com/test-kitchen/test-kitchen
[4]: https://github.com/sethvargo/chefspec
[5]: https://github.com/chef/inspec
[6]: http://berkshelf.com/v2.0/
[7]: https://bundler.io/
[8]: https://ruby.github.io/rake/