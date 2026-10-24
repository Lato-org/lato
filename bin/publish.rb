require "tmpdir"
require_relative "../lib/lato/version"

def run!(*command)
  abort "Command failed: #{command.join(" ")}" unless system(*command)
end

Dir.chdir(File.expand_path("..", __dir__)) do
  version = Lato::VERSION
  branch = IO.popen(["git", "branch", "--show-current"], &:read).strip
  abort "Publish from a named release branch" if branch.empty? || %w[main master].include?(branch)
  abort "Version tag already exists: #{version}" if system("git", "rev-parse", "--verify", "refs/tags/#{version}", out: File::NULL, err: File::NULL)

  Dir.mktmpdir("lato-release-") do |directory|
    artifact = File.join(directory, "lato-#{version}.gem")
    run!("gem", "build", "lato.gemspec", "--output", artifact)
    run!("git", "add", "--all")
    run!("git", "commit", "-m", "chore(release): publish #{version}") unless system("git", "diff", "--cached", "--quiet")
    run!("git", "tag", version)
    run!("gem", "push", artifact)
    run!("git", "push", "--set-upstream", "origin", branch)
    run!("git", "push", "origin", "refs/tags/#{version}")
  end
end
