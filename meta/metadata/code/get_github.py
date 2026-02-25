from github import Github
g = Github()
repo = g.get_repo("uva-bi-sdad/", repo)
print(repo.name)
commits = repo.get_commits(path=path)
print(commits.totalCount)
if commits.totalCount:
    print(commits[0].commit.committer.date)

