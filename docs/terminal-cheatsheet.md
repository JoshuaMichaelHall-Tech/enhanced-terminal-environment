# Enhanced Terminal Environment - Quick Reference

## Shell Commands

### Navigation
| Command | Description |
|---------|-------------|
| `pwd` | Print working directory |
| `ls` | List files |
| `ls -la` | List all files with details |
| `cd dir` | Change to directory |
| `cd ..` | Go up one directory |
| `cd ~` | Go to home directory |
| `cd -` | Go to previous directory |

### File Operations
| Command | Description |
|---------|-------------|
| `mkdir dir` | Create directory |
| `touch file` | Create empty file |
| `cp src dst` | Copy file(s) |
| `mv src dst` | Move/rename file(s) |
| `rm file` | Delete file |
| `rm -r dir` | Delete directory |
| `cat file` | Display file content |
| `less file` | View file with pagination |
| `head file` | Show first 10 lines |
| `tail file` | Show last 10 lines |

### Search
| Command | Description |
|---------|-------------|
| `find . -name "pattern"` | Find files by name |
| `grep "pattern" file` | Search for text in file |
| `grep -r "pattern" dir` | Recursive search |
| `locate filename` | Find file in database |
| `fd pattern` | Modern alternative to find |
| `rg pattern` | Fast recursive search (ripgrep) |

### Permissions
| Command | Description |
|---------|-------------|
| `chmod permissions file` | Change file permissions |
| `chown user:group file` | Change file ownership |
| `sudo command` | Run command as superuser |

### Pipes and Redirection
| Command | Description |
|---------|-------------|
| `cmd1 | cmd2` | Pipe output to another command |
| `cmd > file` | Redirect output to file (overwrite) |
| `cmd >> file` | Redirect output to file (append) |
| `cmd < file` | Use file as input |
| `cmd 2>&1` | Redirect stderr to stdout |

### Process Management
| Command | Description |
|---------|-------------|
| `ps aux` | List all processes |
| `top` or `htop` | Interactive process viewer |
| `glances` | Advanced system monitoring |
| `kill PID` | Kill process by ID |
| `killall name` | Kill processes by name |
| `Ctrl+C` | Interrupt current process |
| `Ctrl+Z` | Suspend current process |
| `bg` | Run suspended process in background |
| `fg` | Bring process to foreground |

## Vim Commands

### Modes
| Command | Description |
|---------|-------------|
| `i` | Enter insert mode |
| `a` | Insert after cursor |
| `A` | Insert at end of line |
| `o` | Insert new line below |
| `O` | Insert new line above |
| `v` | Enter visual mode |
| `V` | Enter visual line mode |
| `Esc` | Return to normal mode |

### Navigation
| Command | Description |
|---------|-------------|
| `h j k l` | Left, down, up, right |
| `w` | Next word |
| `b` | Previous word |
| `0` | Start of line |
| `$` | End of line |
| `gg` | First line |
| `G` | Last line |
| `Ctrl+f` | Page down |
| `Ctrl+b` | Page up |
| `{` | Previous paragraph |
| `}` | Next paragraph |
| `:num` | Go to line number |

### Editing
| Command | Description |
|---------|-------------|
| `x` | Delete character |
| `dd` | Delete line |
| `dw` | Delete word |
| `D` | Delete to end of line |
| `yy` | Copy line |
| `yw` | Copy word |
| `p` | Paste after cursor |
| `P` | Paste before cursor |
| `u` | Undo |
| `Ctrl+r` | Redo |
| `r` | Replace character |
| `cw` | Change word |
| `cc` | Change line |
| `C` | Change to end of line |
| `.` | Repeat last command |

### Search and Replace
| Command | Description |
|---------|-------------|
| `/pattern` | Search forward |
| `?pattern` | Search backward |
| `n` | Next match |
| `N` | Previous match |
| `:%s/old/new/g` | Replace all occurrences |
| `:%s/old/new/gc` | Replace with confirmation |

### Files and Buffers
| Command | Description |
|---------|-------------|
| `:w` | Save file |
| `:q` | Quit |
| `:wq` or `:x` | Save and quit |
| `:e file` | Edit file |
| `:bn` | Next buffer |
| `:bp` | Previous buffer |
| `:bd` | Delete buffer |
| `:ls` | List buffers |

### Windows
| Command | Description |
|---------|-------------|
| `<leader>sv` | Split vertically |
| `<leader>sh` | Split horizontally |
| `<leader>se` | Equal size windows |
| `<leader>sx` | Close window |
| `Ctrl+w h/j/k/l` | Navigate windows |
| `Ctrl+w +/-` | Resize window height |
| `Ctrl+w >/< ` | Resize window width |

## Tmux Commands

### Sessions
| Command | Description |
|---------|-------------|
| `tmux` | Start new session |
| `tmux new -s name` | Start named session |
| `tmux ls` | List sessions |
| `tmux attach -t name` | Attach to session |
| `Ctrl+a d` | Detach from session |
| `Ctrl+a $` | Rename session |
| `Ctrl+a s` | List sessions |
| `Ctrl+a L` | Switch to last session |

### Windows (Tabs)
| Command | Description |
|---------|-------------|
| `Ctrl+a c` | Create window |
| `Ctrl+a ,` | Rename window |
| `Ctrl+a n` | Next window |
| `Ctrl+a p` | Previous window |
| `Ctrl+a 0..9` | Select window by number |
| `Ctrl+a &` | Kill window |
| `Ctrl+a w` | List windows |

### Panes
| Command | Description |
|---------|-------------|
| `Ctrl+a |` | Split vertically |
| `Ctrl+a -` | Split horizontally |
| `Alt+h/j/k/l` | Navigate panes |
| `Ctrl+a z` | Toggle pane zoom |
| `Ctrl+a x` | Close pane |
| `Ctrl+a q` | Show pane numbers |
| `Ctrl+a q 0..9` | Select pane by number |
| `Ctrl+a H/J/K/L` | Resize pane |

### Copy Mode
| Command | Description |
|---------|-------------|
| `Ctrl+a [` | Enter copy mode |
| `q` | Exit copy mode |
| `Space` | Start selection |
| `Enter` | Copy selection |
| `Ctrl+a ]` | Paste |
| `/` | Search forward |
| `?` | Search backward |
| `n` | Next match |
| `N` | Previous match |

## Git & GitHub CLI Commands

### Basic Operations
| Command | Description |
|---------|-------------|
| `git init` | Initialize repository |
| `git clone url` | Clone repository |
| `git status` | Check status |
| `git add file` | Stage changes |
| `git add .` | Stage all changes |
| `git commit -m "msg"` | Commit changes |
| `git push` | Push to remote |
| `git pull` | Pull from remote |

### Branches
| Command | Description |
|---------|-------------|
| `git branch` | List branches |
| `git branch name` | Create branch |
| `git checkout name` | Switch to branch |
| `git checkout -b name` | Create and switch to branch |
| `git merge name` | Merge branch into current |
| `git branch -d name` | Delete branch |

### History
| Command | Description |
|---------|-------------|
| `git log` | View commit history |
| `git log --oneline` | Compact history |
| `git diff` | Show changes |
| `git show commit` | Show commit details |
| `git blame file` | Show who changed what |

### GitHub CLI
| Command | Description |
|---------|-------------|
| `gh auth login` | Authenticate with GitHub |
| `gh repo create` | Create a new repository |
| `gh repo clone` | Clone a repository |
| `gh pr create` | Create a pull request |
| `gh pr list` | List pull requests |
| `gh pr checkout` | Checkout a pull request |
| `gh issue create` | Create an issue |
| `gh issue list` | List issues |

## Docker & Containerization

### Docker Basics
| Command | Description |
|---------|-------------|
| `docker ps` | List running containers |
| `docker ps -a` | List all containers |
| `docker images` | List images |
| `docker pull image` | Pull an image |
| `docker run image` | Run a container |
| `docker build -t name .` | Build an image |
| `docker exec -it container cmd` | Run command in container |
| `docker logs container` | View container logs |
| `docker stop container` | Stop a container |
| `docker rm container` | Remove a container |
| `docker rmi image` | Remove an image |

### Docker Compose
| Command | Description |
|---------|-------------|
| `docker-compose up` | Start services |
| `docker-compose up -d` | Start services in background |
| `docker-compose down` | Stop services |
| `docker-compose logs` | View logs |
| `docker-compose ps` | List containers |
| `docker-compose exec service cmd` | Run command in service |
| `docker-compose build` | Build/rebuild services |

## Database Commands

### PostgreSQL
| Command | Description |
|---------|-------------|
| `psql` | Start PostgreSQL client |
| `\l` | List databases |
| `\c dbname` | Connect to database |
| `\d` | List tables |
| `\d tablename` | Describe table |
| `\q` | Quit |
| `createdb dbname` | Create database |
| `dropdb dbname` | Drop database |

### MongoDB
| Command | Description |
|---------|-------------|
| `mongo` | Start MongoDB shell |
| `show dbs` | List databases |
| `use dbname` | Switch database |
| `show collections` | List collections |
| `db.collection.find()` | Query documents |
| `db.collection.insertOne()` | Insert document |
| `db.collection.updateOne()` | Update document |
| `db.collection.deleteOne()` | Delete document |
| `exit` | Exit shell |

## HTTP Client Tools

### curl
| Command | Description |
|---------|-------------|
| `curl url` | GET request |
| `curl -X POST url` | POST request |
| `curl -H "Header: Value" url` | Add header |
| `curl -d "data" url` | Send data |
| `curl -o file url` | Save output to file |
| `curl -u user:pass url` | Basic auth |
| `curl -L url` | Follow redirects |

### HTTPie
| Command | Description |
|---------|-------------|
| `http url` | GET request |
| `http POST url key=value` | POST request |
| `http url Header:Value` | Add header |
| `http --json url` | Set JSON header |
| `http --form url` | Set form header |
| `http --auth user:pass url` | Basic auth |
| `http --verify=no url` | Skip SSL verification |

## Cloud & Infrastructure Tools

### AWS CLI
| Command | Description |
|---------|-------------|
| `aws configure` | Configure credentials |
| `aws s3 ls` | List S3 buckets |
| `aws s3 cp file s3://bucket/` | Upload to S3 |
| `aws ec2 describe-instances` | List EC2 instances |
| `aws lambda list-functions` | List Lambda functions |
| `aws cloudformation deploy` | Deploy CloudFormation stack |

### Terraform
| Command | Description |
|---------|-------------|
| `terraform init` | Initialize directory |
| `terraform plan` | Create execution plan |
| `terraform apply` | Apply changes |
| `terraform destroy` | Destroy infrastructure |
| `terraform validate` | Validate configuration |
| `terraform fmt` | Format configuration |
| `terraform state list` | List resources |

### Ansible
| Command | Description |
|---------|-------------|
| `ansible-playbook playbook.yml` | Run playbook |
| `ansible host -m ping` | Ping hosts |
| `ansible-galaxy init role` | Initialize role |
| `ansible-vault create file` | Create encrypted file |
| `ansible-vault edit file` | Edit encrypted file |
| `ansible-inventory --list` | List inventory |

## Language Package Managers

### Python (pip/poetry)
| Command | Description |
|---------|-------------|
| `pip install package` | Install package |
| `pip list` | List installed packages |
| `pip freeze > requirements.txt` | Save dependencies |
| `pip install -r requirements.txt` | Install from file |
| `poetry new project` | Create new project |
| `poetry add package` | Add dependency |
| `poetry install` | Install dependencies |
| `poetry shell` | Activate virtual env |
| `poetry run python script.py` | Run in virtual env |

### Node.js (npm/yarn)
| Command | Description |
|---------|-------------|
| `npm init` | Initialize package.json |
| `npm install package` | Install package |
| `npm install -g package` | Install globally |
| `npm install --save-dev package` | Install dev dependency |
| `npm run script` | Run script |
| `npm list` | List packages |
| `npm update` | Update packages |
| `npm publish` | Publish package |

### Ruby (gem/bundler)
| Command | Description |
|---------|-------------|
| `gem install name` | Install gem |
| `gem list` | List installed gems |
| `gem update` | Update gems |
| `gem uninstall name` | Uninstall gem |
| `bundle init` | Create Gemfile |
| `bundle install` | Install dependencies |
| `bundle update` | Update dependencies |
| `bundle exec command` | Run in bundle context |

## Monitoring & Performance Tools

### System Monitoring
| Command | Description |
|---------|-------------|
| `top` | Display processes |
| `htop` | Interactive process viewer |
| `glances` | Advanced monitoring |
| `ps aux` | List all processes |
| `free -h` | Display memory usage |
| `df -h` | Show disk usage |
| `du -sh dir` | Directory size |
| `iostat` | IO statistics |
| `netstat -tuln` | Network connections |

### Text Processing
| Command | Description |
|---------|-------------|
| `grep pattern file` | Search for pattern |
| `awk '{print $1}' file` | Extract first column |
| `sed 's/old/new/g' file` | Find and replace |
| `cut -d, -f1 file.csv` | Extract CSV column |
| `sort file` | Sort lines |
| `uniq` | Remove duplicates |
| `wc -l file` | Count lines |
| `jq '.key' file.json` | Parse JSON |

## Custom Functions

### Tmux Session Functions
| Function | Description |
|----------|-------------|
| `mks name` | Create general dev session |
| `mkpy name` | Create Python session |
| `mkjs name` | Create Node.js session |
| `mkrb name` | Create Ruby session |

### Utility Functions
| Function | Description |
|----------|-------------|
| `vf` | Find and edit file with fzf/preview |
| `proj` | Navigate to project with fzf |
| `dsh` | Shell into Docker container |

### Language-Specific REPLs
| Command | Description |
|---------|-------------|
| `python` | Python REPL |
| `node` | Node.js REPL |
| `irb` | Ruby REPL |
