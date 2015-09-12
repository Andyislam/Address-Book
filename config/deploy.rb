set :application, "Address Book Demo"
set :repository,  "git@github.com:Andyislam/Address-Book.git"

role :web, "your web-server here"                          # Your HTTP server, Apache/etc
role :app, "your app-server here"                          # This may be the same as your `Web` server
role :db,  "your primary db-server here", :primary => true # This is where Rails migrations will run
role :db,  "your slave db-server here"


set(:deploy_to) { "" } #path to deploy in cloud server
set :user, "your deploy user here"
set :password, "your deploy password here"
set :group, "your deploy group here"


set :scm, "git"
set :keep_releases, 5

