maintainer       "Fletcher Nichol"
maintainer_email "fnichol@nichol.ca"
license          "Apache 2.0"
description      "Mirrors git repositories from GitHub"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.1"
recipe            "github_repo_mirror::user", "Mirrors all git repositories for a list of users"

%w{ git }.each do |cb|
  depends cb
end
