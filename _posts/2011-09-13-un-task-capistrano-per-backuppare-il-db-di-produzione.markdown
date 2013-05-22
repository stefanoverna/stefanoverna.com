---
layout: post
date: 2011/09/13
title: Un task Capistrano per backuppare il DB di produzione
---

Recentemente, per riprodurre un bug che si presentava solo in produzione, ho pensato bene di creare un piccolo task Capistrano per copiare in locale l'intero contenuto del DB remoto. Il task funziona solo se il DB di produzione è MySQL. Troverete il risultato nella cartella `backups` del vostro progetto Rails. Eccolo:

{% highlight ruby %}
# config/deploy.rb
require 'yaml'
desc "Backup the remote production database"
task :backup, :roles => :db, :only => { :primary => true } do
  filename = "#{application}.dump.#{Time.now.to_i}.sql.bz2"
  file = "/tmp/#{filename}"
  db = YAML::load(ERB.new(IO.read(File.join(File.dirname(__FILE__), 'database.yml'))).result)['production']
  run "mysqldump -u #{db['username']} --password=#{db['password']} #{db['database']} | bzip2 -c > #{file}"  do |ch, stream, data|
    puts data
  end
  `mkdir -p #{File.dirname(__FILE__)}/../backups/`
  get file, "backups/#{filename}"
end
{% endhighlight %}