# README #

I needed to manage scheduled tasks in OctopusDeploy projects. DSC seemed ideal for my purposes.

However, I couldn't find a pre-existing DSC resource to manage Scheduled Tasks on Windows, so I made one. 

### What is this repository for? ###

An open DSC resource for managing simple scheduled task in Windows. It'll become more complete and complex over time, but for now it:

Creates new tasks
Removes unwanted tasks
Deletes and recreates them if their actions change

### Detailed Setup ###

You will of course need PowerShell v4 and any Desired State Configuration Updates that apply to your system

Tested so far on Windows 8, Server 2012 and 2012 R2. Backward compat is for future testing.

