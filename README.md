
# Sheets Build System

The Sheets build system is a suite of programs used
to debug and distribute your Sheets projects.

This build system manages versions, allowing you to
keep up to date with the latest version of Sheets
with ease. You can easily switch between projects,
all using different versions, and fully customise
how Sheets works using its build preprocessor.

# Setup

First of all, run the installer. Type

```
pastebin run t8ef9mTR
```

and press enter. The Sheets Build System (`sbs`) will
be downloaded. It will ask whether it can modify
`startup` so `sbs` is added to the shell path. By
confirming, it just saves you having to type
`sheets/build/sbs.lua` whenever you do something.
You can instead just type `sbs`.

# Using the build system

First, you'll want to set up a new project. use
```
sbs init project_name --open
```

to create and open a new project. If you want to use an existing folder with your source code, use that folder name as `project_name`. It won't overwrite any source files.

Now, you can add a main file using
```
sbs add file main
```

where `main` is the name of the file.

Edit code in `main`. Sheets will automatically be in the environment, so there's no need to load it yourself. Just remember to prefix anything Sheets related with `sheets.`, so `sheets.Application()` not `Application()`.

A good example script to see if it's working is this:
```lua
local app = sheets.Application()
local button = app.screen + sheets.Button( 1, 1, 20, 5, "Hello world!" )

function button:onClick()
	app:stop()
end

app:run()
```

Now, you're ready to test. Run `sbs debug`, and your program will be executed. The first time you run this, it might take a little longer than you'd want. This is because it will be downloading the version of Sheets you specified (unless it's already installed) and rebuilding it. Later debugs will skip this step as the build file is cached, so it will run much quicker.

Type in `sbs help` for more information.
