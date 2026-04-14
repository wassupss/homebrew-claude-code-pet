class ClaudeCodePet < Formula
  desc "CLI pet that grows with your Claude Code usage"
  homepage "https://github.com/wassupss/homebrew-claude-code-pet"
  url "https://github.com/wassupss/homebrew-claude-code-pet/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "PLACEHOLDER"
  version "1.0.0"
  license "MIT"

  depends_on "python3"

  def install
    libexec.install "libexec/pet.py"
    libexec.install "setup-hooks.py"
    bin.install "bin/claude-pet"
    chmod 0755, bin/"claude-pet"
  end

  def post_install
    system Formula["python3"].opt_bin/"python3", libexec/"setup-hooks.py", "install"
  rescue
    # Hook setup is non-fatal — user can run manually via caveats
  end

  def caveats
    <<~EOS
      Claude Code Pet has been installed!

      To finish setup, add hooks to Claude Code:
        python3 #{libexec}/setup-hooks.py install

      Usage:
        claude-pet          # watch mode (interactive)
        claude-pet roll     # gacha roll
        claude-pet play     # chat with your pet
        claude-pet codex    # species codex

      To remove hooks on uninstall:
        python3 #{libexec}/setup-hooks.py uninstall
    EOS
  end

  test do
    system bin/"claude-pet", "status"
  end
end
