PD_ROOT = "/opt/pd"
RB_VERSION = "2.2.2"
PACKAGES = {
  "pd-ruby" => "2.2.2",
  "pd-emitter" => "0.0.5",
  "pd-emitter-daemon" => "0.0.1",
  "pd-emitter-plugins-all" => "0.0.1",
  "pd-emitter-plugin-pdex" => "1.0.0",
}

require "tmpdir"
RBENV_ROOT = "#{PD_ROOT}/ruby"

def mount_overlayfs(lower, upper, mountpoint)
  sh "mount -t overlayfs -o lowerdir=#{lower},upperdir=#{upper} overlayfs #{mountpoint}"
  yield
  sh "umount #{mountpoint}"
end

desc "dist-clean. remove deb/ cache/ build/"
task "dist-clean" do
  sh("umount -a -t overlayfs") {|_, _|} # ignore fail
  rm_rf ["deb/", "cache/", "build/"]
end

desc "Cleanup deb/ and cache/"
task :clean do
  sh("umount -a -t overlayfs") {|_, _|} # ignore fail
  rm_rf ["deb/", "cache/"]
end

directory PD_ROOT

directory "build/pd-ruby"
desc "build pd-ruby"
file "build/pd-ruby" => [PD_ROOT] do |t|
  ENV["RBENV_ROOT"] = RBENV_ROOT
  ENV["PATH"] = "#{RBENV_ROOT}/bin:#{ENV['PATH']}"
  Dir.mktmpdir { |tmp|
    mount_overlayfs(tmp, t.name, PD_ROOT) do
      sh "git clone https://github.com/sstephenson/rbenv.git #{RBENV_ROOT}"
      sh 'eval "$(rbenv init -)"'
      sh "git clone https://github.com/sstephenson/ruby-build.git #{tmp}"
      sh "PREFIX=$(rbenv root) #{tmp}/install.sh"
      sh "rbenv install #{RB_VERSION}"
      sh "echo '#{RB_VERSION}' > $(rbenv root)/version"
      gem = "#{RBENV_ROOT}/versions/#{RB_VERSION}/bin/gem"
      sh "#{gem} update --no-document"
    end
  }
end

directory "build/pd-emitter"
desc "build pd-emitter"
file "build/pd-emitter" => ["build/pd-ruby"] do |t|
  mount_overlayfs(t.prerequisites[0], t.name, PD_ROOT) do
    gem = "#{RBENV_ROOT}/versions/#{RB_VERSION}/bin/gem"
    sh "#{gem} install fluentd specific_install --no-ri --no-rdoc"
    sh "#{gem} specific_install -l https://github.com/ma2shita/fluent-plugin-in_unix_unimsg.git"
    sh "git clone https://github.com/plathome/pd-emitter.git #{PD_ROOT}/emitter"
  end
end

directory "cache/pd-emitter"
desc "pd-ruby + pd-emitter into cache/pd-emitter for plugin install base"
file "cache/pd-emitter" => ["build/pd-ruby", "build/pd-emitter"] do |t|
  t.prerequisites.each {|i|
    sh "rsync -ap #{i}/ #{t.name}/"
  }
end

directory "build/pd-emitter-daemon"
desc "build pd-emitter-daemon"
file "build/pd-emitter-daemon" => ["cache/pd-emitter"] do |t|
  conf = <<EOT
[supervisord]
nocleanup=true

[program:pd-emitter]
directory = #{PD_ROOT}/emitter/
command = #{PD_ROOT}/emitter/bin/rake start
redirect_stderr = true
autostart = false
autorestart = true
stderr_logfile=/var/webui/logs/pd-emitter-stderr.log
stderr_logfile_maxbytes=5MB
stderr_logfile_backups=2
stdout_logfile=/var/webui/logs/pd-emitter-stdout.log
stdout_logfile_maxbytes=5MB
stdout_logfile_backups=2
umask=644
environment=CONF="/var/webui/config/pd-emitter.conf"

[group:main]
programs = pd-emitter
priority = 999
EOT
  open(File.join(t.name, "pd-emitter.conf"), "w"){|fd| fd.write conf}
end

directory "build/pd-emitter-plugin-pdex"
desc "build pd-emitter-plugin-pdex"
file "build/pd-emitter-plugin-pdex" => ["cache/pd-emitter"] do |t|
  mount_overlayfs(t.prerequisites[0], t.name, PD_ROOT) do
    plugin_version = "1.0.0"
    gem = "#{RBENV_ROOT}/versions/#{RB_VERSION}/bin/gem"
    gemdir = `#{gem} environment gemdir`.strip
    plugin_root = "#{gemdir}/gems/pd-emitter-plugin-pdex-#{plugin_version}"
    sh "#{gem} specific_install -l https://ssl.plathome.co.jp/git/git/pd/pd-emitter-plugin-pdex.git"
    cp "#{plugin_root}/share/pd_pdex_v1_ob.binstub",     "#{PD_ROOT}/emitter/bin/stubs/pd_pdex_v1_ob"
    cp "#{plugin_root}/share/pd_pdex_v1_ob.driver.conf", "#{PD_ROOT}/emitter/conf/driver.d/pd_pdex_v1_ob.conf"
  end
end

directory "build/pd-emitter-plugins-all"
desc "build pd-emitter-plugins-all"
file "build/pd-emitter-plugins-all" => ["build/pd-emitter-plugin-pdex"] do |t|
  nil # NOTE: Pseudo package. Therefore, nothing todo.
end

desc "Create ~/.devscripts"
file "#{File.expand_path('~')}/.devscripts" do |t|
  open(t.name, "w"){|fd|
    fd.write 'DEBUILD_LINTIAN_OPTS="--profile ignore-opt-dir -i --allow-root --verbose"'
  }
end

_lintian_dir = "#{File.expand_path('~')}/.lintian/profiles/ignore-opt-dir"
directory _lintian_dir
desc "Create lintian profile"
file "#{_lintian_dir}/main.profile" => _lintian_dir do |t|
  open(t.name, "w"){|fd|
    fd.write <<EOT
Profile: ignore-opt-dir/main
Extends: debian/main
Disable-Tags: dir-or-file-in-opt
EOT
  }
end

task :all do
  PACKAGES.each do |k, v|
    Rake::Task["deb/#{k}_#{v}"].invoke
  end
end

PACKAGES.each {|k, v|
  directory "cache/#{k}-debian"
  task "cache/#{k}-debian" do |t|
    rm_rf "#{t.name}/*"
    sh "rsync -ap #{k}-debian/ #{t.name}"
  end

  directory "deb/#{k}-#{v}"
  desc "build deb for #{k}_#{v}"
  task "deb/#{k}_#{v}" => ["build/#{k}", "cache/#{k}-debian", "deb/#{k}-#{v}"] do |t|
    mount_overlayfs(t.prerequisites[0], t.prerequisites[1], t.prerequisites[2]) do
      sh "tar cjf #{t.name}.orig.tar.bz2 -C build/ #{k}"
      Dir.chdir(t.prerequisites[2]) {
        sh "debuild -uc -us"
      }
    end
  end
}

