---
layout: post
title: Deploy rapidi con Capistrano
---

Niente di che, percarità, ma quando `cap deploy` inizia a metterci cinque buoni minuti, averlo fa comodo.

```ruby
# deploy.rb
namespace :deploy do
  task :fast, :roles => :app do
    run "cd #{current_path} && git pull origin master && rake deployer:all_rake_tasks RAILS_ENV=production && touch tmp/restart.txt"
  end
end
```

Ovviamente, fatelo partire con `cap deploy:fast`.
