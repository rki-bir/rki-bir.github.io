# FROM: https://github.com/raivivek/rubyscholar and ORIGINALLY: https://github.com/wurmlab/rubyscholar

```bash
conda create -y -n rubyscholar -c conda-forge ruby
gem install bundler:1.11.2
```

Then added 
```
  gem.add_runtime_dependency "racc", "~> 1.4.0", ">= 1.4.0"
```
to `rubyscholar.gemspec` to avoid the chek for `racc`

```
bundle install
bundle exec rubyscholar
```