# Releasing rubocop-prose

Release only with explicit maintainer authorization. Release preparation happens on `main`; never force-push `main`.

## Prepare

Update `main` with a fast-forward pull. Run `bundle exec rake` and confirm GitHub Actions checks pass, including the separate interoperability workflow. Verify the minimum supported RuboCop with `RUBOCOP_VERSION=1.72.1 bundle install` and `RUBOCOP_VERSION=1.72.1 bundle exec rake spec`; restore the normal dependency resolution afterward. Interoperability currently uses rubocop-md PR #57; update its workflow ref when the original-source mapping API is released.

Set the version in `lib/rubocop/prose/version.rb`, date its CHANGELOG heading as `YYYY/MM/DD`, remove the contribution placeholder from that release, and check README installation instructions. Commit and push preparation changes, wait for green CI, then build and inspect the package:

```sh
bundle exec rake build
gem specification pkg/rubocop-prose-0.1.0.gem files
```

Confirm runtime code, configuration, cop guides, README, CHANGELOG, licenses, and artwork are present; exclude tests, temporary workspaces, and dependency caches. Preserve the vendored helmet license and provenance. Install the exact built gem into a temporary gem environment outside the checkout and exercise plugin loading, discovery, stdin, configuration, and repeated autocorrection for Markdown and text.

## Publish

Publish the exact inspected package. Enter a fresh RubyGems MFA code when prompted; never put credentials or codes in source, logs, or documentation.

For an assistant-driven release, ask the maintainer for a fresh MFA code only when ready to publish and pass it through `GEM_HOST_OTP_CODE`, not the `--otp` command-line argument. Prefer a hidden local prompt. If the maintainer explicitly chooses chat, explain that the code will be visible in conversation history. Never save the code in repository files or documentation. Alternatively, the maintainer can run `gem push` interactively.

```sh
gem push pkg/rubocop-prose-0.1.0.gem
```

Verify that exact version on RubyGems before creating and pushing an annotated `v0.1.0` tag at the release commit. Create a GitHub release with matching changelog notes. Do not move an existing release tag.

## Next development iteration

Bump the gem version, add a matching `(Next)` CHANGELOG section with `- Your contribution here.`, then commit and push to `main`.
