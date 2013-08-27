desc 'Running Jekyll with --server --auto opition'
task :dev do
  system('jekyll serve --watch')
end

desc 'Deploy site'
task :deploy do
  system('jekyll build')
  system('rsync -avz --no-p --no-g --chmod=ugo=rwX -e ssh _site/ stefanoverna.com:/home/128423/users/.home/domains/stefanoverna.com/html')
end

