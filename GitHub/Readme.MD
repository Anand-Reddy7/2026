# GitHub



## What are the advantages and disadvantages of Git rebase?

```text
The main advantage of rebase is that it creates a clean, linear Git history, keeps the feature branch updated with the latest base branch, and allows us to clean up commits before creating a PR. The main disadvantages are that it rewrites commit history and changes commit IDs, can cause problems on shared branches, may require a force push, and conflict resolution can become complicated. So I normally use rebase on private feature branches and avoid rebasing shared branches.
```

```text
                 Git Branch
                     │
          ┌──────────┴──────────┐
          │                     │
     Private branch         Shared branch
          │                     │
        REBASE                MERGE
          │                     │
          ↓                     ↓
   Clean history          Preserve history




# Before Rebase
A---B---C---D---M1---M2    main
         \
          F1---F2          feature




# After Rebase
A---B---C---D---M1---M2---F1'---F2'
                              ↑
                           feature
```

# Git CherryPick 

Take one specific commit from another branch and apply that commit to my current branch.

```
feature ── A ── B ── C
                 │
                 │ cherry-pick B
                 ↓
main ─────────── B'


git switch release
git cherry-pick abc1234
git push origin release
```

# Git Bisect ( Finding Which Commit Introduced a Bug )

Git Bisect uses binary search to find the commit that introduced a bug.

"I would use git bisect. I'd mark the current commit as bad and the last known working commit as good. Git performs a binary search and checks out a middle commit. I'd test the application and mark each checked commit as either good or bad. Git continues narrowing the range until it identifies the first bad commit. Finally, I'd inspect it with git show and run git bisect reset."

```text

Imagine you have 100 commits:

A---B---C---D---E---F---G---H---I---J
                                ↑
                              BUG
```

```shell
git bisect start
git bisect bad
git bisect good <known-good-commit>

# test

git bisect good
# OR
git bisect bad

# repeat

git bisect reset
```

## Real time Example

```shell
anandreddy@Anand's MacBook Pro 2026 % git bisect good ebc37ad
Bisecting: 6 revisions left to test after this (roughly 3 steps)
[cf24617a4e5b2b24d0b596f6c8aa229c5ef70c8c] Linux Learning
anandreddy@Anand's MacBook Pro 2026 % git bisect good cf24617
Bisecting: 3 revisions left to test after this (roughly 2 steps)
[bfc4c38027d9b8f70f0b28f8a9f5ebd59edabca0] Kerberos integration with OpenLDAP
anandreddy@Anand's MacBook Pro 2026 % git bisect good bfc4c38
Bisecting: 1 revision left to test after this (roughly 1 step)
[884820fc66eda3e4717ef397328e4f4cec65775d] Ansible Doc
anandreddy@Anand's MacBook Pro 2026 % git bisect bad 884820f 
Bisecting: 0 revisions left to test after this (roughly 0 steps)
[17f9a0211aa4d9c28f2f1ac7a12b5b97cda88b0c] Nginx Doc
anandreddy@Anand's MacBook Pro 2026 % git bisect bad 17f9a02
17f9a0211aa4d9c28f2f1ac7a12b5b97cda88b0c is the first bad commit
commit 17f9a0211aa4d9c28f2f1ac7a12b5b97cda88b0c (HEAD)
Author: Anand.Reddy7 <Anand.Reddy7@ibm.com>
Date:   Sat Aug 22 22:53:38 2026 +0530

    Nginx Doc

 Linux/Networking.MD  |  66 +++++++++++++++++++++++++++++++++
 Linux/README.MD      | 200 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 Nginx/Error_Codes.MD | 296 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 Nginx/README.MD      | 305 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 866 insertions(+), 1 deletion(-)
 create mode 100644 Nginx/Error_Codes.MD
 create mode 100644 Nginx/README.MD
anandreddy@Anand's MacBook Pro 2026 % git show --stat
commit 17f9a0211aa4d9c28f2f1ac7a12b5b97cda88b0c (HEAD)
Author: Anand.Reddy7 <Anand.Reddy7@ibm.com>
Date:   Sat Aug 22 22:53:38 2026 +0530

    Nginx Doc

 Linux/Networking.MD  |  66 +++++++++++++++++++++++++++++++++
 Linux/README.MD      | 200 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 Nginx/Error_Codes.MD | 296 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 Nginx/README.MD      | 305 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 866 insertions(+), 1 deletion(-)
anandreddy@Anand's MacBook Pro 2026 % 
```

# Git Blame (Finding who changed a particular line)

git blame shows which commit and author last modified each line of a file. I use it when I need to trace a particular line back to the commit that introduced or changed it. After finding the commit, I can use git show <commit-id> to inspect the actual change."

```shell
git blame <file>
git blame -L 10,20 <file>
git show <commit-id>
```

# Git Submodules (Managing another Git repository inside a repo)

A Git submodule allows you to include one Git repository inside another Git repository. 

The submodule is a separate Git repository, but the parent repository tracks which commit of that repository it should use.

```
Main Repository
│
├── README.md
├── docker/
├── scripts/
│-- .gitmodules
└── external-project/    ← another Git repository
      ├── file1
      ├── file2
      └── .git
```

## .gitmodules

It contains information about the submodule. It tells what is "Submodule name" and where it is located and what is the path etc..

```
[submodule "common-library"]
    path = common-library
    url = https://github.com/company/common-library.git
```

# GIT reflog (Recover deleted commits/branches)

"git reflog records changes to Git references such as HEAD and branch pointers in my local repository. I mainly use it to recover commits or previous states after operations like reset, rebase, or accidentally moving a branch. I can find the previous commit using reflog and then restore it using commands such as git reset or by creating a recovery branch."


git reflog is Git's local safety net for finding where your branches and HEAD used to point.

```shell
git reflog
git reflog --oneline
git show HEAD@{2}

# Recovery
git branch recovery <commit-id>

# Or restore branch
git reset --hard <commit-id>
```


# Git Worktree (Multiple working directories)


Git worktree allows you to have multiple working directories for the same Git repository, with different branches checked out in each directory.

```
                    Git Repository
                         │
             ┌───────────┼───────────┐
             ↓           ↓           ↓
         Worktree 1   Worktree 2   Worktree 3
             │           │           │
           main       feature       hotfix
```

git worktree allows me to create multiple working directories from the same Git repository, with different branches checked out in each directory. It's useful when I need to work on multiple branches simultaneously without stashing or cloning the repository again.