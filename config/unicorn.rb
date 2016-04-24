# ワーカーはコア数の2倍にする
worker_processes Facter["processorcount"].value.to_i * 2

timeout 15

preload_app true

pid "/var/run/books-unicorn.pid"
listen "/var/run/books-unicorn.sock"

# 子プロセスを作成する前に実行する処理をブロック内に記述
before_fork do |server, worker|
  # マスタープロセスがコネクションを維持する必要はないからコネクションを切断しておく
  defined?(ActiveRecord::Base) and
      ActiveRecord::Base.connection.disconnect!

  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

end

# 子プロセスを作成した後に実行する処理をブロック内に記述
after_fork do |server, worker|
  # 接続する
  defined?(ActiveRecord::Base) and
      ActiveRecord::Base.establish_connection

  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

end
# ./はRailsアプリがあるディレクトリを示す
stdout_path "./log/unicorn.stdout.log"
stderr_path "./log/unicorn.stderr1.log"
