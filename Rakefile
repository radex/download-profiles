require "bundler"
Bundler.setup

gemspec = eval(File.read("download-profiles.gemspec"))

task :build => "#{gemspec.full_name}.gem"

file "#{gemspec.full_name}.gem" => gemspec.files + ["download-profiles.gemspec"] do
  system "gem build download-profiles.gemspec"
end
