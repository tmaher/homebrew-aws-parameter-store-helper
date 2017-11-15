require 'formula'
require 'language/go'

AWSPS = 'aws-parameter-store-helper'.freeze

# Homebrew formula to install ssh password asker
class AwsParameterStoreHelper < Formula
  homepage  "https://github.com/tmaher/#{AWSPS}/"
  url       "https://github.com/tmaher/#{AWSPS}/archive/v0.1.2.tar.gz"
  sha256    '50156985fca5814c5151c04e6a7d9dc645329970d37520442636f883733bb097'

  depends_on 'go'       => :build
  depends_on 'govendor' => :build

  github_dependencies = {
    'aws/aws-sdk-go'      => 'beafda230a3568820b4de838683c0efd3c1b9af2',
    'codegangsta/cli'     => 'a2943485b110df8842045ae0600047f88a3a56a1',
    'keybase/go-keychain' => '18e96b8b8ccf5706fbba9d97a82cbb009720bf02',
    'pkg/errors'          => 'f15c970de5b76fac0b59abb32d62c17cc7bed265',
    'spf13/cobra'         => '2da4a54c5ceefcee7ca5dd0eea1e18a3b6366489',
    'spf13/pflag'         => '4c012f6dcd9546820e378d0bdda4d8fc772cdfea'
  }
  golang_dependencies = {
    'crypto'              => '5dc8cb4b8a8eb076cbb5a06bc3b8682c15bdbbd3'
  }

  github_dependencies.each do |repo, hashref|
    go_resource "github.com/#{repo}" do
      url "https://github.com/#{repo}.git", revision: hashref
    end
  end

  golang_dependencies.each do |repo, hashref|
    go_resource "golang.org/x/#{repo}" do
      url "https://go.googlesource.com/#{repo}.git", revision: hashref
    end
  end

  def install
    contents = Dir['{*,.git,.gitignore}']
    gopath   = buildpath / 'gopath'
    (gopath / "src/github.com/tmaher/#{AWSPS}").install contents

    ENV['GOPATH'] = gopath
    ENV.prepend_create_path 'PATH', gopath / 'bin'
    Language::Go.stage_deps resources, gopath / 'src'

    cd gopath / "src/github.com/tmaher/#{AWSPS}" do
      system 'go', 'install'
      bin.install gopath / "bin/#{AWSPS}"
      bin.install_symlink(bin / AWSPS => bin / 'aws-ps')
    end
  end
end
