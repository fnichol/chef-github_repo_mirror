#
# Cookbook Name:: chef-github_repo_mirror
# Recipe:: user
#
# Copyright 2010, Fletcher Nichol
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "git"

require 'yaml'
require 'open-uri'

GITHUB_API_URL = "http://github.com/api/v2/yaml/repos/show"

base_path = "/var/mirror/github"

node[:github_repo_mirror][:user].each do |user|

  directory "/var/mirror/github/#{user}" do
    recursive true
  end

  repos = YAML.load(open("#{GITHUB_API_URL}/#{user}").read)["repositories"]
  repos.map! { |repo| repo[:url].sub(/^https?/, "git") << ".git" }
  repos.each do |repo|

    repo_path = "#{user}/#{repo.split('/').last}"

    bash "update #{repo}" do
      cwd File.join(base_path, repo_path)
      code %{git fetch}
      only_if %{test -d #{File.join(base_path, repo_path)}}
    end

    bash "create #{repo} mirror" do
      cwd "/var/mirror/github/#{user}"
      code %{git clone --mirror #{repo}}
      creates File.join(base_path, repo_path, "config")
    end

    cron "schedule #{repo} mirroring" do
      hour "5"
      minute "0"
      command %{cd #{File.join(base_path, repo_path) && git fetch -q}}
    end
  end
end

