# Contribution Guidelines
Thanks for taking you time to improve this GitHub repository.

## Version
Currently, the versioning system is:
+ Increment the patch version(`0.0.x`) sometimes when I feel like it.
+ Increment the minor version(`0.x.0`) when there are breaking changes.
    + Tipicaly this is happens when I refactor/rewrite the whole codebase.

Will uses [Semantic Versioning 2.0.0](https://semver.org/) upon version 1.0.0

## Test
To test the repository run `:checkhealth ultimate-autopair`.
Note that this DOES NOT test all the features of the plugin.
It only tests the testing system and default profile.
If you want to run development checks and tests, set `_G.UA_DEV` to `true`.

## Branch
It is recommended to use the `development` branch when creating a pull request and not the main branch, as the `development` branch is where nightly updates can be found.

## Commit messages
Commit messages should follow the [Conventional Commits](https://conventionalcommits.org/) format.
