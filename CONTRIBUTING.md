# Contribution Guidelines
Thanks for taking you time to improve this GitHub repository.

## Version
Currently, the versioning system is:
+ Increment the patch version(`0.0.x`) sometimes when I feel like it.
+ Increment the minor version(`0.x.0`) when there are major breaking changes.
    + Tipicaly this is happens when I refactor/rewrite the whole codebase.

## Test
To run the tests: set `_G.UA_DEV=true` and run `:checkhealth ultimate-autopair` (you can ignore non-test warnings).

## Branch
It is recommended to use the `development` branch when creating a pull request and not the main branch, as the `development` branch is where nightly updates can be found.

## Commit messages
Commit messages should follow the [Conventional Commits](https://conventionalcommits.org/) format.
