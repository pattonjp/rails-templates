# create rvmrc file
say 'running rvm'
rvmrc = <<-RVMRC
rvm_gemset_create_on_use_flag=1
rvm gemset use #{app_name}
RVMRC

create_file ".rvmrc", rvmrc

remove_file     "public/index.html"
remove_file     "public/images/rails.png"


gem "rails3-generators", :group => [ :development ]
gem "rspec"
gem "rspec-rails", :group => [ :development, :test ]
gem "jquery-rails"
gem "mongo_mapper"
gem "bson_ext"
gem "factory_girl_rails"
run "bundle install"


generate 'jquery:install --ui'
generate 'rspec:install'

file 'spec/factories.rb', <<-ERB
  # factories go here...
  
  Factory.define :user do |u|
    u.username              "some_username"
    u.email                 "some_usernamemail.com"
    u.password              "foobar"
    u.password_confirmation "foobar"
  end
ERB


inject_into_file 'spec/spec_helper.rb', "\nrequire 'factory_girl'", :after => "require 'rspec/rails'"

generators = <<-GENERATORS
      config.generators do |g|
        g.orm :mongo_mapper
        g.template_engine :erb
        g.test_framework :rspec
        g.fixture_replacement :factory_girl, :dir => 'spec/factories'
      end
  GENERATORS

application generators

# remove active_resource and test_unit
gsub_file 'config/application.rb', /require 'rails\/all'/, <<-CODE
  require 'rails'
  require 'active_record/railtie'
  require 'action_controller/railtie'
  require 'action_mailer/railtie'
  require "sprockets/railtie"
CODE

generate "mongo_mapper:config"

run "echo '--format documentation' >> .rspec"

remove_file 'public/javascripts/rails.js' # jquery-rails replaces this

# clean up rails defaults
remove_file 'public/index.html'
remove_file 'rm public/images/rails.png'




file '.gitignore', <<-END
.bundle
log/*.log
*.log
tmp/**/*
tmp/*
Gemfile.lock
.DS_Store
public/index.html
coverage/*
coverage.data
doc/api
doc/app
*.swp
*~
rerun.txt
.autotest_images
autotest_images
.idea
.autotest
END

run "bundle install"

# commit to git
git :init
git :add => "."
git :commit => "-a -m 'create initial application'"
