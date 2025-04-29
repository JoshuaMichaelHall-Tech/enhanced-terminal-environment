# Database Workflows

This guide provides terminal-based workflows for PostgreSQL and MongoDB Atlas databases within the Enhanced Terminal Environment.

## PostgreSQL Workflow

### Installation and Setup

PostgreSQL is pre-installed as part of the Enhanced Terminal Environment. The installation script configures it with sensible defaults.

```bash
# Check PostgreSQL installation
postgres --version

# Start PostgreSQL service (macOS)
pgstart

# Check service status
pgstatus
```

### Basic Database Operations

```bash
# Connect to PostgreSQL
psql

# Connect to a specific database
psql mydatabase

# Create a new database
createdb mydatabase

# Drop a database
dropdb mydatabase

# Backup a database
pgbackup mydatabase

# Restore a database
pgrestore mydatabase backup_file.sql
```

### Common psql Commands

Once connected to PostgreSQL via `psql`:

```sql
-- List all databases
\l

-- Connect to a database
\c mydatabase

-- List tables in current database
\dt

-- Describe a table
\d table_name

-- Execute a query
SELECT * FROM table_name LIMIT 10;

-- Get help on psql commands
\?

-- Execute SQL from a file
\i file.sql

-- Quit psql
\q
```

### Terminal Integration

The Enhanced Terminal Environment provides custom functions for database management:

```bash
# Database connection helper (select from multiple databases)
dbsh

# Create a PostgreSQL database
pgcreate mydatabase

# Backup a PostgreSQL database
pgbackup mydatabase [output-file]

# Restore a PostgreSQL database
pgrestore mydatabase input-file.sql
```

## MongoDB Atlas CLI Workflow

### Installation and Authentication

MongoDB Atlas CLI is pre-installed as part of the Enhanced Terminal Environment.

```bash
# Check installation
atlas --version

# Authenticate with MongoDB Atlas
atlas auth login
```

### Cluster Management

```bash
# List all your clusters
atlas clusters list

# Get details about a specific cluster
atlas clusters describe <cluster-name>

# Connect to a cluster
atlas clusters connect <cluster-name>
```

### Database Operations

```bash
# List databases in a project
atlas databases list --projectId <project-id>

# List database users
atlas databases users list --projectId <project-id>

# Create a database user
atlas databases users create --username <username> --password <password> --role <role> --projectId <project-id>
```

### Project Management

```bash
# List all your projects
atlas projects list

# Create a new project
atlas projects create <project-name>

# Delete a project
atlas projects delete <project-id>
```

### Data Operations with mongosh

For direct data manipulation, you can use MongoDB Shell (mongosh):

```bash
# Install MongoDB Shell if not included
brew install mongosh  # macOS
sudo apt install mongodb-mongosh  # Ubuntu/Debian

# Connect to your cluster (get connection string from Atlas UI or CLI)
mongosh "mongodb+srv://cluster0.example.mongodb.net/myDatabase" --username <username>

# Once connected, you can perform data operations:
use myDatabase
db.collection.find()
db.collection.insertOne({ name: "example", value: 42 })
db.collection.updateOne({ name: "example" }, { $set: { value: 43 } })
db.collection.deleteOne({ name: "example" })
```

### Custom Aliases

The Enhanced Terminal Environment provides convenient aliases for MongoDB Atlas CLI:

```bash
# MongoDB Atlas CLI
alias atl="atlas"                # Main command shortcut
alias atlc="atlas clusters"      # Cluster management
alias atld="atlas databases"     # Database management  
alias atlp="atlas projects"      # Project management
alias atll="atlas logs"          # Log management
```

## Database Integration with Terminal Tools

### Using Databases with Neovim

You can integrate database queries directly into your Neovim workflow:

```vim
" Execute a selection in psql (install vim-database plugin first)
:'<,'>DB postgresql://user:pass@localhost/mydatabase

" Or use the built-in terminal
:term psql mydatabase
```

### Database Sessions with Tmux

Create specialized database sessions with the following tmux configurations:

```bash
# Create a database-focused session
tmux new-session -s db \
  -n psql "psql mydatabase" \
  -n atlas "atlas clusters list" \
  -n mongosh "mongosh"
```

### Database Backups with Cron

Set up automated backups using cron:

```bash
# Open crontab editor
crontab -e

# Add a daily backup at 2 AM
0 2 * * * $HOME/.local/bin/pgbackup mydatabase ~/backups/db_$(date +\%Y\%m\%d).sql
```

## Troubleshooting Common Issues

### PostgreSQL Connection Issues

```bash
# Restart PostgreSQL server
pgstop && pgstart

# Check PostgreSQL log
tail -f /var/log/postgresql/postgresql-*.log  # Linux
tail -f /usr/local/var/log/postgres.log       # macOS

# Verify PostgreSQL is listening
netstat -tuln | grep 5432
```

### MongoDB Atlas Connectivity

```bash
# Check your network connection to Atlas
atlas connectivity test

# View connection errors in logs
atlas logs list --type "DEPLOYMENT" --limit 10
```

## Advanced Database Workflows

### Multi-Database Migrations

For applications with both PostgreSQL and MongoDB databases:

```bash
# Export data from PostgreSQL to JSON
psql mydatabase -c "COPY (SELECT row_to_json(t) FROM mytable t) TO STDOUT" > data.json

# Import JSON into MongoDB
mongoimport --uri "mongodb+srv://..." --collection mycollection --file data.json
```

### Performance Monitoring

Monitor database performance with:

```bash
# PostgreSQL performance
psql -c "SELECT * FROM pg_stat_activity;"

# MongoDB performance stats
atlas metrics processes <cluster-name> \
  --granularity PT1M \
  --period P1D
```

---

For more detailed information and advanced usage scenarios, refer to:
- [PostgreSQL Official Documentation](https://www.postgresql.org/docs/)
- [MongoDB Atlas CLI Documentation](https://www.mongodb.com/docs/atlas/cli/stable/)
