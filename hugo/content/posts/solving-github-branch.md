---
title: "A Solution to Changing Branch on GitHub"
date: 2025-09-15
draft: false
tags: ["dev", "github"]
categories: ["tips"]
description: "A weird bug on GitHub causing an impossibility to switch repository branch."
---
![](/images/posts/github-changing-branch-impossible.jpg)
This is a PSA for anyone having trouble changing the branch on their repository.


While GitHub allows switching the main branch on their platform, it can be dangerous to do so when dealing with pull requests and cloned repositories. It can however be necessary in specific situations (such as a first push targeting the wrong branch).

## The Process

In such a case, you can easily go to your repository's general settings.

![](/images/posts/github-changing-branch-settings.jpg)

![](/images/posts/github-changing-branch-general-settings.jpg)

![](/images/posts/github-changing-branch-general-settings.jpg)

![](/images/posts/github-changing-branch-default.jpg)

This is where things get awry. If you see the following error message at the top of the page:


It means you are on mobile and switching did not work.

## The Solution

To remedy this problem, you'll have to either use a PC or put your browser in **desktop mode**.

![](/images/posts/github-changing-branch-desktop.jpg)

Try again and it should work like nothing happened.
