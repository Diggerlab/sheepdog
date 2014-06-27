worker_processes 1

app_root = File.expand_path("../..", __FILE__)
# we use a shorter backlog for quicker failover when busy
listen "/tmp/unicorn.sheepdog.sock", :backlog => 64
listen 9530, :tcp_nopush => false

# nuke workers after 30 seconds instead of 60 seconds (the default)
timeout 30

# feel free to point this anywhere accessible on the filesystem
pid "#{app_root}/tmp/pids/unicorn.pid"

stderr_path "#{app_root}/log/unicorn.stderr.log"
stdout_path "#{app_root}/log/unicorn.stdout.log"