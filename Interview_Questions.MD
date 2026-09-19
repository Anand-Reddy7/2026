# GitHub

## 1. How to recover the deleted branch ?
 
```shell
If a branch is accidentally deleted, I first identify the last commit using the PR, GitHub history, or git reflog. Then I recreate the branch from that commit and push it back to the remote using git push origin <branch-name>
```

### If you know the last commit SHA

```shell
git checkout -b my-branch <commit-sha>
git push origin my-branch
```

### If the branch was deleted through a GitHub Pull Request

```shell
GitHub often provides a "Restore branch" button on the closed/merged PR.

Open the PR → look near the bottom → Restore branch.
```

## 2. How do you check whether a branch has been merged into main?

### To check branches merged:
```shell
Use git branch --merged
```

### To check branches not merged:

```shell
git branch --no-merged main
```

### Check a specific branch ?

```shell
git merge-base --is-ancestor feature/ldap main
echo $?

## git merge-base --is-ancestor balu develop 
##  echo $?
0
``` 

I can use git branch --merged main to list branches that have been merged into main, and git branch --no-merged main for branches that haven't. For checking one specific branch, I can use git merge-base --is-ancestor feature/branch main and check the exit status.
