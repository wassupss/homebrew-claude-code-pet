class ClaudeCodePet < Formula
  desc "CLI pet that grows with your Claude Code usage"
  homepage "https://github.com/wassupss/homebrew-claude-code-pet"
  url "https://github.com/wassupss/homebrew-claude-code-pet/archive/refs/tags/v1.0.2.tar.gz"
  sha256 "c20696728afc7d61c3abf73924795141237fdafa6f4249c3abcd195bec76468e"
  version "1.0.2"
  license "MIT"

  depends_on "python3"

  def install
    libexec.install "libexec/pet.py"
    libexec.install "setup-hooks.py"

    # Generate wrapper with the exact python3 path — no system python3 required
    python3 = Formula["python3"].opt_bin/"python3"
    (bin/"claude-pet").write <<~SH
      #!/bin/bash
      exec "#{python3}" "#{libexec}/pet.py" "$@"
    SH
    chmod 0755, bin/"claude-pet"
  end

  def post_install
    # Hook setup requires home directory access — sandboxed, so non-fatal
    system Formula["python3"].opt_bin/"python3", libexec/"setup-hooks.py", "install"
  rescue StandardError
    # User can run: claude-pet setup
  end

  def caveats
    <<~EOS
      Claude Code Pet has been installed!

      Run this to connect your pet to Claude Code:
        claude-pet setup

      Usage:
        claude-pet          # watch mode (interactive)
        claude-pet roll     # gacha roll
        claude-pet play     # chat with your pet
        claude-pet codex    # species codex

      To remove hooks:
        claude-pet setup uninstall
    EOS
  end

  test do
    system bin/"claude-pet", "status"
  end
end
