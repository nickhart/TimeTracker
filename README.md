# TimeTracker
An iOS Time Tracker app with billing, analytics, and report generation.

## Overview

I found myself needing a time tracker app so I could accurately track time spent on various projects for different clients, generate reports, and bill the clients. There are plenty of apps like these out there, but I also wanted to build one from scratch as a practice to re-familiarize myself with modern Swift after spending a few years mostly doing Typescript/React and management.

## Features

- support multiple clients
- multiple projects per client
- multiple tasks per project
- customizable billing rates
- customizable time increments
- an easy to use timer with OS integrations
  - live activities
  - local notifications
- analytics
- report generation (CSV)
- offline support

## Architecture decisions

- Swift 5.10
- SwiftUI
- CoreData w/CloudKit

## Offline support

- Simple mechanism to handle synching via multiple sources
- Don't sync active timers
- last one wins (if you are trying to use this simultaneously from two devices be careful!)

## AI support

I designed this project myself and used Claude Code to help get a bunch of the scaffolding and tooling off the ground. The overall project structure is informed by my own experience and what I believe are to be solid code organization practices. The tools in `scripts` are helpers for me to use via CLI, Git pre-commit hooks, and GitHub CI workflows.

Claude helped me write the scripts, as well as the GitHub and Git integrations. Claude also helped me configure the Homebrew dependencies, SwiftLint, and SwiftFormat. I also prefer to use VSCode for my non-Xcode editing (markdown, scripts, YAML, JSON), so I have included some VSCode settings and markdownlint configuration.
