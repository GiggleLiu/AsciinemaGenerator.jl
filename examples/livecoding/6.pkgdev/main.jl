#s delay=1
using Pkg

# check existing registry (a Github repo for indexing packages)
Pkg.Registry.status()

# check where to download the package and binaries
ENV["JULIA_PKG_SERVER"]

# create a new package
using PkgTemplates

# GiggleLiu is my github handle ;D
tpl = Template(; user="GiggleLiu", plugins=[
    # run tests on both latest Julia and nightly build
    GitHubActions(; extra_versions=["nightly"]),
    Git(),
    # the CI for checking test coverage
    Codecov(),
    # deploy documentation with GitHubActions
    Documenter{GitHubActions}(),
])

# generate a new package with the template
tpl("Demo")

# package root directory
rootdir = joinpath(homedir(), ".julia", "dev", "Demo")

# goto the root dir
cd(rootdir)

# show the file structure
# NOTE: tree is a shell utility, windows users can check the corresponding folder manually
run(`tree`);

##################  Purpose of each file  ####################
# 
# ├── docs
# │   ├── make.jl                 # The make file for the documents
# │   ├── Manifest.toml           # The resolved dependency for the `docs` environment
# │   ├── Project.toml            # The dependency specification for the `docs` environment
# │   └── src
# │       └── index.md            # The document home page
# ├── .github
# │   └── workflows               # Files in this folder specify jobs run by Github Action automatically.
# │       ├── CI.yml              # Run tests and calculate the test coverage
# │       ├── CompatHelper.yml    # Help your package dependency up to date by creating a pull request.
# │       └── TagBot.yml          # Auto-tag a version after registering a new version in a Julia registry.
# ├── .gitignore      # Ignored files will not be considered a part of the `git` repo.
# ├── LICENSE         # MIT license by default
# ├── Manifest.toml   # The resolved dependency
# ├── Project.toml    # The package name, UUID and dependencies
# ├── README.md       # README in markdown format
# ├── src             # The folder for Julia source code
# │   └── Demo.jl     # The main file for the `Demo` module
# └── test            # The folder for Julia test code
#     └── runtests.jl # The main file for testing.

#+ 10
# Package version and dependency
println(read("Project.toml", String))

# show the current environment directory
Pkg.status()

# working in the local environment for you package
Pkg.activate(".")
# NOTE: to deactivate, use `Pkg.activate()`
Pkg.status()

# add a dependency for your package
Pkg.add("Primes")
# it is recommended to edit the [compat] section in the Project.toml too.
# check https://pkgdocs.julialang.org/v1/compatibility/ to learn more abount version number specification.
#
# check the version of packages
Pkg.status()